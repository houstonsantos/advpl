## MDFe

### DAMDFE

Função responsável pela impressão do documento fiscal.

### MDFESEFAZ

Função responsável pelo funcionamento da rotina MDF-e.

---

## NFe

### Imagem da DANFE

Caso tenha mais de uma empresa o parâmetro **MV_LOGOD** precisa está como **.T.** (True).

---

## NFs

### Arquivos NFSEXml*.prw

Fontes padrão para nota fiscal de serviço.

---

## Produto

### Prodseq

Função que gera o código do produto automático, concatenando o código do grupo com o sequencial automático.

### ProdCodBar

SetCodBarProd - Função que define o código de barras para o produto que está sendo cadastrado
baseado no padrão EAN8

GetNumberCodBar - Recebe uma string com 7 caracteres e calcula o código de controle do código de barras
Lembrando que atualmente a função contempla apenas o padrão EAN8

---

## CriaTab.prw

Fonte utilizado em montagens de ambiente para inclusão de registros nas tabelas, SX2, SX3, SIX, SXA, SX7 e SXB

Sempre que necessário incluir um registro em uma destas tabelas de forma dinâmica, é utilizado uma função deste arquivo fonte.

---

## Filtros.prw

Arquivo utilizado para armazenar os filtros por expressões que criamos para atender o usuário final.
