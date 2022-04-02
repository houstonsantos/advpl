# Fechamento Financeiro

##  Funções e Métodos

#### Blok

O método Blok cria a tela onde será informada a data do fechamento.

#### Blofin

A função Blofin verifica se o usuário está autorizado a utilizar a rotina.
***

##  Informações complementares

Foi necessário a criação do parâmetro MV_BLOKFIN.


### Parâmetros

| Filial    | Nome da variável | Tipo     | Descrição                                                                               |
| --------- | ---------------- | -------- | --------------------------------------------------------------------------------------- |
| Branco | MV_BLOKFIN        | Caracter | Determina quais usuários podem executar a rotina.                                      |
| Branco | MV_DATAFIN        | Caracter | Determina a data em que serão iniciadas as movimentações financeiras                   |
| Branco | MV_BXDTFIN        | Caracter | determina se as operações de baixas a pagar e a receber considerarão a data definida no parâmetro MV_DATAFIN.                  |
