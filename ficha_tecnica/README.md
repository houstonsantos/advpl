# __Ficha Técnica__

- ## __FichaTecExec.prw__

    Implementa todos os métodos de manipulação e execução da rotina MVC criada para contemplar o cadastro da ficha técnica customizado no Protheus. Para que a implementação realize a construção das opções de ficha no browse do produto é necessário incluir os parâmetros descritos abaixo.

- ## __FichaTecMvc.prw__
  Fonte que define as funções da rotina de ficha técnica, além da implementação MVC este fonte também customiza a view com a criação das abas programáticamente.

---

## __Ambiente__

-  ### __Parâmetros__

        Nome: MV_FICHAPR 
        Valor: .T.
        Detalhes: Define a implementacao de ficha tecnica do produto para a empresa. Através deste parâmetro é que o ponto de entrada do Browser da SB1 irá identificar a necessidade de se adicionar mais uma opção no menu funcional com o nome de "Ficha Técnica".

-  ### __Tabelas__

        Nome: ZFT 
        Descrição: Armazena as informações complementares do produto que contemplam a ficha técnica, como por exemplo se o produto é
        vegano ou não, forma de regeneração e etc...

        Nome: ZIN 
        Descrição: Armazena as informações do grid que contempla as informações nutricionais do produto

- #### __Lembrando que para esta customização as tabelas e índices são criados automaticamente pela rotina.__
    