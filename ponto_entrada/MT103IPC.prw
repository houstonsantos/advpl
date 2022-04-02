#include "protheus.ch"


/*/{Protheus.doc} MT103IPC
    (Ponto de entrada para importação de pedido em pré-nota, alimentado a descrição do produto em D1_XDESCRI)
    @type  Function
    @author Houston Santos
    @since 10/06/2019
    @version version
    @param param
    @return return
    @see (http://tdn.totvs.com/display/public/PROT/MT103IPC+-+Atualiza+campos+customizados+no+Documento+de+Entrada)
/*/

User Function MT103IPC()
    
    Local _nLinha := PARAMIXB[1]
    Local _cDescr := SC7->C7_DESCRI
    Local _cCusto := SC7->C7_CC
    
    aCols[_nLinha][AScan(aHeader, {|x|AllTrim(x[2]) == "D1_XDESCRI"})] := _cDescr
    aCols[_nLinha][AScan(aHeader, {|x|AllTrim(x[2]) == "D1_CC"})] := _cCusto
    
Return(.T.)
