//Bibliotecas
#Include "Protheus.ch"

User Function MT110GET 

    Local aRet:= PARAMIXB[1]
    aRet[2,1] := 81 //Abaixando o começo da linha da getdados
    aRet[1,3] := 78 // Abaixando a linha de contorno dos campos do cabeçalho

Return aRet
