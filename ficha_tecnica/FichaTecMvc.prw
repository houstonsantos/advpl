#include 'protheus.ch'
#include 'fwmvcdef.ch'


/*/{Protheus.doc} FichaTecMvc
    (long_description)
    @type  Function
    @author Gleyber Cavalcanti
    @since 15/10/2019
    @version version
    @param none
    @return none
    @example
    (examples)
    @see (links_or_references)
/*/

User Function FichaTecMvc()

    Local oBrowse := FwLoadBrw("FichaTecMvc")
    oBrowse:Activate()

Return Nil


Static Function BrowseDef()

    Local oBrowse := FwMBrowse():New()
    oBrowse:SetAlias("ZFT")
    oBrowse:SetDescription(OemToAnsi('Ficha técnica de produto'))
    oBrowse:SetMenuDef("FichaTecMvc")   

Return oBrowse


Static Function MenuDef()

    Local oMenu := FWMVCMenu("FichaTecMvc")
    
Return oMenu


Static Function ModelDef()
    
    // Variáveis do programa
    Local oModel    := Nil
    Local oStrFicha := FWFormStruct(1, "ZFT")
    Local oStrGrid  := FWFormStruct(1, 'ZIN')
    Local oStrPrepa := FWFormStruct(1, 'ZPR')
    Local aZINRel   := {}
    Local aZPRRel   := {}
    
    // Definições dos campos e inicialização
    oStrFicha:SetProperty('ZFT_CODPRO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'AllTrim(SB1->B1_COD)')) 
    oStrGrid:SetProperty( 'ZIN_CODPRO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'AllTrim(SB1->B1_COD)'))
    oStrPrepa:SetProperty('ZPR_CODPRO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'AllTrim(SB1->B1_COD)'))

    // Criando o modelo e adicionando o field e grid
    oModel := MPFormModel():New("ZFTModel", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)
    oModel:AddFields('ZFTMASTER', /*cOwner*/, oStrFicha)
    oModel:AddGrid('ZINDETAIL'  ,'ZFTMASTER', oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPos*/, /*bLoad*/)
    oModel:AddGrid('ZPRDETAIL'  ,'ZFTMASTER', oStrPrepa, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPos*/, /*bLoad*/)

    // Fazendo o relacionamento entre o Pai e Filho
    aAdd(aZINRel, {'ZIN_CODPRO','ZFT_CODPRO'})
    aAdd(aZPRRel, {'ZPR_CODPRO','ZFT_CODPRO'})

    // IndexKey -> quero a ordenação e depois filtrado
    oModel:SetRelation('ZINDETAIL', aZINRel, ZIN->(IndexKey(1)))
    oModel:SetRelation('ZPRDETAIL', aZPRRel, ZPR->(IndexKey(1)))
    
    // Define a validação valor único no campo de descrição
    // Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:GetModel('ZINDETAIL'):SetUniqueLine({"ZIN_DESC"}) 
    oModel:GetModel('ZPRDETAIL'):SetUniqueLine({"ZPR_FORMA"})
    
    // Define a chave do model
    oModel:SetPrimaryKey({"ZFT_CODPRO"})

    // Setando as descrições
    oModel:GetModel('ZFTMASTER'):SetDescription('Dados')
    oModel:GetModel('ZINDETAIL'):SetDescription(OemToAnsi('Informações Nutricionais'))
    oModel:GetModel('ZPRDETAIL'):SetDescription(OemToAnsi('Formas de Preparo'))
	
Return oModel


Static Function ViewDef()

    // Variáveis do programa
	Local oView	    := Nil
	Local oModel    := FWLoadModel("FichaTecMvc")
    Local oStrFicha := FWFormStruct(2, 'ZFT')
    Local oStrDicas := FWFormStruct(2, 'ZFT')
    Local oStrIngal := FWFormStruct(2, 'ZFT')
    Local oStrGrid  := FWFormStruct(2, 'ZIN')
    Local oStrPrepa := FWFormStruct(2, 'ZPR')
	
	// Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
    
    // Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_ZFT'      , oStrFicha, 'ZFTMASTER') 
    oView:AddField('VIEW_ZFT_DICAS', oStrDicas, 'ZFTMASTER') 
    oView:AddGrid('VIEW_ZIN'       , oStrGrid , 'ZINDETAIL')
    oView:AddGrid('VIEW_ZPR'       , oStrPrepa, 'ZPRDETAIL')
    oView:AddField('VIEW_ZFT_INGAL', oStrIngal, 'ZFTMASTER')

    // Criando abas 'Ficha técnica' e 'Dicas e receitas'
    oView:CreateFolder("PASTA_PRINCIPAL")
    oView:AddSheet('PASTA_PRINCIPAL','ABA_FICHA', OemToAnsi('Ficha técnica'))
    oView:AddSheet('PASTA_PRINCIPAL','ABA_DICAS', OemToAnsi('Dicas e receitas'))
    oView:AddSheet('PASTA_PRINCIPAL','ABA_INGAL', OemToAnsi('Ingredientes e alégicos'))
    oView:AddSheet('PASTA_PRINCIPAL','ABA_PREPA', OemToAnsi('Formas de preparação'))
    
    // Definindo o tamanho das caixas
	oView:CreateHorizontalBox('VIEW_FICHA_CABEC',  58,,, "PASTA_PRINCIPAL", "ABA_FICHA")
    oView:CreateHorizontalBox('VIEW_FICHA_GRID' ,  42,,, "PASTA_PRINCIPAL", "ABA_FICHA")
    oView:CreateHorizontalBox('VIEW_DICAS'      , 100,,, "PASTA_PRINCIPAL", "ABA_DICAS")
    oView:CreateHorizontalBox('VIEW_INGAL'      , 100,,, "PASTA_PRINCIPAL", "ABA_INGAL")
    oView:CreateHorizontalBox('VIEW_PREPA'      , 100,,, "PASTA_PRINCIPAL", "ABA_PREPA")

	// Amarrando a view com as box
    oView:SetOwnerView('VIEW_ZFT'      , 'VIEW_FICHA_CABEC')
    oView:SetOwnerView('VIEW_ZIN'      , 'VIEW_FICHA_GRID')
    oView:SetOwnerView('VIEW_ZFT_DICAS', 'VIEW_DICAS')
    oView:SetOwnerView('VIEW_ZPR'      , 'VIEW_PREPA')
    oView:SetOwnerView('VIEW_ZFT_INGAL', 'VIEW_INGAL')

	// Habilitando título
    oView:EnableTitleView('VIEW_ZFT'      , OemToAnsi('Dados'))
    oView:EnableTitleView('VIEW_ZFT_DICAS', OemToAnsi('Dicas / Combinações / Harmonizações / Receitas'))
    oView:EnableTitleView('VIEW_ZIN'      , OemToAnsi('Informações nutricionais'))
    oView:EnableTitleView('VIEW_ZFT_INGAL', OemToAnsi('Ingredientes e alérgicos'))
    oView:EnableTitleView('VIEW_ZPR'      , OemToAnsi('Formas de preparo'))
	
	// Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

    // Remoção de campos na aba Ficha Técnica
    oStrFicha:RemoveField('ZFT_FILIAL')
    oStrFicha:RemoveField('ZFT_DICAS' )  
    oStrFicha:RemoveField('ZFT_RECEIT')
    oStrFicha:RemoveField('ZFT_INGRED')
    oStrFicha:RemoveField('ZFT_ALERGI')

    // Remoção de campos no grid
    oStrGrid:RemoveField('ZIN_CODPRO') 
    oStrGrid:RemoveField('ZIN_FILIAL') 

    // Remoção de campos no grid
    oStrPrepa:RemoveField('ZPR_CODPRO') 
    oStrPrepa:RemoveField('ZPR_FILIAL') 
    
    // Remoção de campos na aba Dicas e receitas
    oStrDicas:RemoveField('ZFT_FILIAL')
    oStrDicas:RemoveField('ZFT_CODPRO')
    oStrDicas:RemoveField('ZFT_GLUTEM')
    oStrDicas:RemoveField('ZFT_LACTOS')
    oStrDicas:RemoveField('ZFT_INTEGR')
    oStrDicas:RemoveField('ZFT_VEGANO')
    oStrDicas:RemoveField('ZFT_LIGHT' )
    oStrDicas:RemoveField('ZFT_DIET'  )
    oStrDicas:RemoveField('ZFT_INGRED')
    oStrDicas:RemoveField('ZFT_ALERGI')
    oStrDicas:RemoveField('ZFT_QRCODE')
    oStrDicas:RemoveField('ZFT_DESCRI')

    // Remoção de campos na aba Ingredientes e alérgicos
    oStrIngal:RemoveField('ZFT_FILIAL')
    oStrIngal:RemoveField('ZFT_CODPRO')
    oStrIngal:RemoveField('ZFT_GLUTEM')
    oStrIngal:RemoveField('ZFT_LACTOS')
    oStrIngal:RemoveField('ZFT_INTEGR')
    oStrIngal:RemoveField('ZFT_VEGANO')
    oStrIngal:RemoveField('ZFT_LIGHT' )
    oStrIngal:RemoveField('ZFT_DIET'  )
    oStrIngal:RemoveField('ZFT_DICAS' )
    oStrIngal:RemoveField('ZFT_RECEIT')
    oStrIngal:RemoveField('ZFT_QRCODE')
    oStrIngal:RemoveField('ZFT_DESCRI')
    
Return oView