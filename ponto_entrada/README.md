:warning: 
# Pontos de Entrada

### A390ZERO
Possibilita ao usuário a criação de lote com saldo zerado, com pegunta

https://tdn.totvs.com/pages/releaseview.action?pageId=6087915

---

### EMP650
Edição de Itens Empenhados na Abertura da OP - A implementação automatiza a tela de empenho a selecionar o armazém definido na MV_XLOCPRD
caso não exista, seleciona o armazém 90

https://tdn.totvs.com/pages/releaseview.action?pageId=6087997

---

### F080BENEF
Atribuir a razão social **(SA2->A2_NOME)** como beneficiário no cheque **(SEF->EF_BENEF)** no momento da baixa. 

http://tdn.totvs.com/pages/releaseview.action?pageId=236424444

---

### F470ALLF 
Permite vizualizar extrato bancário de forma consolidada para usuários que não tenham permissão nas empresas e que tenham o saldo compartilhado SE8. 

http://tdn.totvs.com/pages/releaseview.action?pageId=6071573

---

### FA560BRW 
Adiciona a rotina de movimentações do caixinha FINA560 o botão de conhecimento para anexar arquivos. 

https://tdn.totvs.com/pages/releaseview.action?pageId=167313546

---

### FTMSREL
Ponto de entrada que permite a criação de uma chave primária de usuário para ser adicionado a funcionalidade de "Conhecimento"
com isto, é possível incluir a tela de inclusão de documentos para uma customização proprietária de usuário.

https://tdn.totvs.com/display/public/PROT/FTMSREL

---

### M020EXC
Ponto de entrada (Exclusão de Fornecedor) com algumas modificações para adequação ao nosso ambiente
**ATENÇÃO:** A implementação atual deste ponto não está sendo considerada no ambiente de produção pois o bloco
não conseguiu ser executado após testes com exclusão do registro de fornecedor.

---

### M020INC
Pontos de entrada criados para complementar o cadastro do fornecedor, este ponto é executo após a inclusão de um novo fornecedor sua implementação consiste em criar e/ou associar um item contábil. Para que a empresa desejada passe a considerar estas rotinas, é necessário criar um parâmetro do tipo lógico com o nome de MV_ITMCTBL (Lógico) com o valor .T.

https://tdn.totvs.com/pages/releaseview.action?pageId=6087546

---

### M030EXC
Ponto de entrada (Exclusão do cliente) com algumas modificações para adequação ao nosso ambiente
**ATENÇÃO:** A implementação atual deste ponto não está sendo considerada no ambiente de produção pois o bloco está sendo 
executado antes da confirmação de exclusão do cliente, podendo gerar um erro caso a exclusão for cancelada

https://tdn.totvs.com/pages/releaseview.action?pageId=6784134

---

### M030INC
Pontos de entrada criados para complementar o cadastro do cliente, este ponto é executo após a inclusão de um novo cliente sua implementação consiste em criar e/ou associar um item contábil. Para que a empresa desejada passe a considerar estas rotinas, é necessário criar um parâmetro do tipo lógico com o nome de MV_ITMCTBL (Lógico) com o valor .T.

https://tdn.totvs.com/pages/viewpage.action?pageId=6784136

---

### M261BCHOI
**Montagem de array com botões na tela de inclusão** - Fonte disponibilizado pelo analista da TOTVS que estava fazendo a implantação do módulo PCP,
a sua implementação adiciona a tela de transferências entre armazém a possibilidade de selecionar uma ordem de produção, e carregar todos os itens
da ordem para serem transferidos de acordo com o empenho da mesma.

https://tdn.totvs.com/pages/releaseview.action?pageId=6087569

---

### M460FIM 
Executado na preparação do documento de saída para manipulação das informações, neste exemplo alimenta a tabela SE1 com informações de dois campos do tipo data(competência) utilizado no pedido de venda, C5_XCOMIN -> E1_XCOMIN e C5_XCOMFI -> E1_XCOMFI. OBS: para que a empresa desejada passe a considerar esta rotina, é necessário criar um parâmetro do tipo lógico com o nome de MV_COMPCON (Competência de consumo) com o valor igual a .T.

http://tdn.totvs.com/pages/releaseview.action?pageId=6784180

---

### MA020TDOK 
**Validação das consistências após a digitação da tela de Fornecedores** - Ponto de entrada com algumas modificações para
se adequar ao nosso ambiente.. A sua implementação realiza a associação de um item contábil (CTD) com um fornecedor (SA2).
**ATENÇÃO:** NÃO COMPILAR ESTE FONTE EM PRODUÇÃO, POIS O FONTE M020INC.prw JÁ ENCONTRA-SE REALIZANDO A MESMA FUNÇÃO IMPLEMENTADA.

http://tdn.totvs.com/pages/releaseview.action?pageId=6085756

---

### MA080MNU
Ponto de entrada habilitar opção cópia de TES. 

http://tdn.totvs.com/pages/releaseview.action?pageId=6784261

---

### MATA070NH
Ponto de entrada MVC no cadastro de Bancos, para cadastro do Item Contábil na CTD. 

http://tdn.totvs.com/display/public/mp/Pontos+de+Entrada+para+fontes+Advpl+desenvolvidos+utilizando+o+conceito+MVC

---

### MT020FIL
Ponto de entrada para inclusão de campos na tabela FIL, para atender CNAB de terceiros. 

https://tdn.totvs.com/pages/releaseview.action?pageId=185756465

---

### MT100GE2 
Executo após a classificação do documento, utilizado para manipula informações do tituloa pagar, neste exemplo levo o centro de custo e código de barras informado. O centro de custo só será levado em casos em que sejam iguais para todos os itens ou informado na duplicata, em casos de diferença nos itens, não levara pois neste caso deve-se se realizar o rateio. Deve-se utilizar em comjunto com o MT103SE2. 

http://tdn.totvs.com/pages/releaseview.action?pageId=6085781

---

### MT103DNF
**Validação dos campos existentes no Folder "Informações Danfe" e "Nota Fiscal Eletrônica"** - Caso a especie da nota fiscal que está sendo classificada
for igual a "SPED", a implementação valida se o campo de CHAVE NFE foi preenchido, contém 44 caracteres, todos numéricos e com dígito verificador válido.

https://tdn.totvs.com/pages/releaseview.action?pageId=6085666

---

### MT103IPC
Ponto de entrada que traz o centro de custo e descrição do produto **(C7_CC / C7_DESCRI)** do pedido para **SD1 (D1_CC / D1_DESCPRO)**. 

http://tdn.totvs.com/display/public/PROT/MT103IPC+-+Atualiza+campos+customizados+no+Documento+de+Entrada

---

### MT103SE2 
Manipula o aCols da SE2 utilizado no documento de entrada, executado em conjunto com o MT100GE2. 

http://tdn.totvs.com/pages/releaseview.action?pageId=6085675

---

### MTA010MNU
Ponto de entrada referente ao momento de montagem do browser de produto SB1/MATA010 a implementação 
adiciona mais uma opção de menu com submenu referente a ficha técnica e impressão das etiquetas. 

https://tdn.totvs.com/pages/releaseview.action?pageId=370617549

---

### PE01NFESEFAZ
Ponto de entrada criado para fazer a complementação das informações adicionais das notas fiscais.
E usado o **TES** (Tipo de Entrada e Saída) 530 para isenção de **ICMS** (Imposto sobre Circulação de Mercadoria e Serviço).
Os campos F2_MENNOTA e C5_MENNOTA devem ficar iguais com tamanho 250.
**CONFORME CONVÊNIO DE ICMS N° 73/2004 E DECRETO LEI N° 14876/91 E DECRETO N° 27541/2005.** 

http://tdn.totvs.com/pages/releaseview.action?pageId=274327446
https://tdn.totvs.com/pages/releaseview.action?pageId=238028227

---
