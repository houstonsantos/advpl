# Crédito Funcionário

```
.
├── README.md
└── src
    ├── CredFin.prw
    └── CredFunc.prw

1 directory, 3 files
```

## CredFin

A Função recebe por parâmetro um array e inseri os dados aglutinados por centro de custo nas tabelas **SE2** (Contas a pagar), **SEV** (Rateio por natureza) e **SEZ** (Rateio por centro de custo).

Ordem do array: Prefixo, Número do título, Tipo, Natureza, Fornecedor, Loja, Data de emissão, Data de vencimento, Centro de custo e Valor.
___

## CredFunc

A Função gera um arquivo de remessa **CNAB folha de pagamento layout 200** Bradesco.
___
            
## Informações complementares

#### Tabela ZCR

É preciso criar a tabela **ZCR** (Tabela Credito da Remessa) com os seguintes campos:

| Campo  | Tipo  | Tamanho | Decimal | Formato  | 
| ------ | ----- | ------- | ------- | -------- | 
| ZCR_FILIAL | Caracter | 2   | 0    | @!    |           
| ZCR_COD    | Caracter | 6   | 0    | @!    |  
| ZCR_CC     | Caracter | 9   | 0    | @!    |                              
| ZCR_SEQREG | Caracter | 6   | 0    |       |                            
| ZCR_NATURE | Caracter | 10  | 0    | @!    |   
| ZCR_VALOR  | Numérico | 12  | 2    | @E 999,999,999.99 |                         
| ZCR_DATAG  | Data     | 8   | 0    |       |   

---

#### Tabela ZZC
É preciso criar a tabela **ZZC** (Credito Funcionario) com os seguintes campos, nessa mesma ordem:

| Campo      | Tipo     | Tamanho | Decimal | Formato           | Validação                                                                                                                | Uso         |
| ---------- | -------- | ------- | ------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------ | ----------- |
| ZZC_FILIAL | Caracter | 2       | 0       | @!                |                                                                                                                          | Obrigatório |
| ZZC_NOME   | Caracter | 40      | 0       | @!                | Cons. Padrão = ZZCNOM - Zzcnom                                                                                           | Obrigatório |
| ZZC_COD    | Caracter | 6       | 0       | @!                | Val. Sistema = NaoVazio() .And. EXISTCHAV("ZZC",M->ZZC_COD) .And. Val(M->ZZC_COD) > 0 .And. FreeForUse("ZZC",M->ZZC_COD) | Obrigatório |
| ZZC_CPF    | Caracter | 11      | 0       | @R 999.999.999-99 | Val. Sitema = If(Empty(M->ZZC_CPF),.T.,ChkCPF(M->ZZC_CPF)) .AND. FHIST()                                                 | Obrigatório |
| ZZC_AGEN   | Caracter | 5       | 0       | @R XXXXX          |                                                                                                                          | Obrigatório |
| ZZC_CONTA  | Caracter | 8       | 0       | @R XXXXXXXX       |                                                                                                                          | Obrigatório |
| ZZC_CC     | Caracter | 9       | 0       | @!                | CTB105CC() .And. FHIST()                                                                                                 | Obrigatório |
| ZZC_VALOR  | Numérico | 12      | 2       | @E 999,999,999.99 |                                                                                                                          | Obrigatório |
| ZZC_OK     | Caracter | 1       | 0       | @!                |                                                                                                                          |             |
---

#### Consulta padrão ZZCNOM.

É preciso criar a consulta padrão **ZZCNOM**

| Tipo da consulta | Tabela | Habilitar inclusão | Índices | Colunas | Retorno |
| ---------------- | ------ | ------------------ | ------- | ------- | ------- |
| Consulta padrão  | SRA    | SIM                | Índices | Colunas | Retorno |

- Índices
    - CPF
    - Nome + Matricula
    - Centro de Custo + Matricula
    - Matricula

- Colunas
    - CPF
    - Nome
    - Matricula
    - Centro de custo

- Retorno
    - SRA->RA_NOME
    - SRA->RA_MAT
    - SRA->RA_CIC
    - Substr(SRA->RA_BCDEPSA,4,8)
    - SRA->RA_CTDEPSA
    - SRA->RA_CC