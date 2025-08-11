USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON btFirst LABEL "<<".
DEFINE BUTTON btBack  LABEL "<".
DEFINE BUTTON btNext  LABEL ">".
DEFINE BUTTON btLast  LABEL ">>".
DEFINE BUTTON btAdd   LABEL "Adicionar" SIZE 14 BY 1.
DEFINE BUTTON btMod   LABEL "Modificar" SIZE 14 BY 1.
DEFINE BUTTON btDel   LABEL "Deletar"   SIZE 14 BY 1.
DEFINE BUTTON btSave  LABEL "Salvar"    SIZE 14 BY 1.
DEFINE BUTTON btCanc  LABEL "Cancelar"  SIZE 14 BY 1.
DEFINE BUTTON btExp   LABEL "Exportar"  SIZE 14 BY 1.
DEFINE BUTTON btExit  LABEL "Sair"      SIZE 14 BY 1 AUTO-ENDKEY.

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE QUERY qProduto FOR produtos.

DEFINE BUFFER bProduto FOR produtos.

DEFINE FRAME fProduto
    btFirst            AT 2
    btBack 
    btNext 
    btLast             SPACE(3)
    btAdd 
    btMod 
    btDel              SPACE(3)
    btSave 
    btCanc             SPACE(3)
    btExp              SPACE(4)
    btExit             SKIP(1) 
    produtos.CodProduto  COLON 20 
    produtos.NomeProduto COLON 20    
    produtos.ValProduto  COLON 20
    WITH SIDE-LABELS THREE-D SIZE 140 BY 15
         VIEW-AS DIALOG-BOX TITLE "Produtos".

{C:/dados/movButtons.i &query=qProduto}

ON 'choose' OF btAdd DO:
    ASSIGN cAction = "add".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
   
    CLEAR FRAME fProduto.
    DISPLAY NEXT-VALUE(seqProduto) @ produtos.CodProduto WITH FRAME fProduto.
END.

ON 'choose' OF btMod DO:
    ASSIGN cAction = "mod".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
   
    DISPLAY produtos.CodProduto WITH FRAME fProduto.
    RUN piDisp.
END.

ON 'choose' OF btDel DO:  
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER bProduto FOR produtos.
    
    MESSAGE "Confirma a exclusão do produto" produtos.CodProduto "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Exclusão".
    IF  lConf THEN DO:
        FIND bProduto
            WHERE bProduto.CodProduto = produtos.CodProduto
            EXCLUSIVE-LOCK NO-ERROR.
        IF  AVAILABLE bProduto THEN DO:
            IF NOT CAN-FIND(itens WHERE itens.CodProduto = bProduto.CodProduto) THEN DO:
                DELETE bProduto.
                RUN piOpenQuery.  
                GET PREV qProduto.
                RUN piDisp.
            END.
            ELSE DO:
                MESSAGE "Produto possui pedidos associados e não pode ser excluido"
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.
        END.
    END.
END.      

ON 'choose' OF btSave DO:
   IF cAction = "add" THEN DO:
        CREATE bProduto.
        ASSIGN bProduto.CodProduto  = INPUT produtos.CodProduto.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bProduto
            WHERE bProduto.CodProduto = produtos.CodProduto
            EXCLUSIVE-LOCK NO-ERROR.
   END.
   
   ASSIGN bProduto.NomeProduto = INPUT produtos.NomeProduto.
          bProduto.ValProduto = INPUT produtos.ValProduto.

   RUN piEnableButtons (INPUT TRUE).
   RUN piEnableFields (INPUT FALSE).
   RUN piOpenQuery.
END.

ON 'choose' OF btCanc DO:
    RUN piEnableButtons (INPUT TRUE).
    RUN piEnableFields (INPUT FALSE).
    RUN piDisp.
END.

ON CHOOSE OF btExp DO:
// exportar para csv
    DEFINE VARIABLE cArqCsv AS CHARACTER NO-UNDO.
    ASSIGN cArqCsv = SESSION:TEMP-DIRECTORY + "xtudo.csv".
    OUTPUT TO VALUE(cArqCsv).
    FOR EACH produtos NO-LOCK:
        PUT UNFORMATTED
            produtos.CodProduto  ";"
            produtos.NomeProduto ";"
            produtos.ValProduto  ";".
        PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqCsv).
// exportar para JSON
    DEFINE VARIABLE cArqJSON AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE oObj     AS JsonObject NO-UNDO.
    DEFINE VARIABLE aProdutos AS JsonArray  NO-UNDO.
    
    ASSIGN cArqJSON = SESSION:TEMP-DIRECTORY + "xtudo.json".
    aProdutos = new JsonArray().
    FOR EACH produtos NO-LOCK:
        oObj = new JsonObject().
        oObj:add("CodigoProduto", produtos.CodProduto).
        oObj:add("Nome", produtos.NomeProduto).
        oObj:add("Valor", produtos.ValProduto).
        aProdutos:add(oObj).
    END.
    aProdutos:WriteFile(INPUT cArqJSON, INPUT yes, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqJSON).
END.

RUN piOpenQuery.
RUN piEnableButtons(INPUT TRUE).
APPLY "choose" TO btFirst.
//VIEW FRAME fProduto.
//DISPLAY produtos WITH FRAME fProduto.

WAIT-FOR WINDOW-CLOSE OF FRAME fProduto.

PROCEDURE piDisp:
    IF AVAILABLE produtos THEN DO:
        DISPLAY produtos.CodProduto produtos.NomeProduto produtos.ValProduto
             WITH FRAME fProduto.
    END.
    ELSE DO:
        CLEAR FRAME fProduto.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF  AVAILABLE produtos THEN DO:
        ASSIGN rRecord = ROWID(produtos).
    END.
    
    OPEN QUERY qProduto 
        FOR EACH produtos.
    
    GET FIRST qProduto.
END PROCEDURE.

PROCEDURE piEnableButtons:
    {c:/dados/enableButtons.i &tab=produtos &frame=fProduto}.
END PROCEDURE.

PROCEDURE piEnableFields:
    {c:/dados/enableFields.i &frame=fProduto &tab=produtos &field1= NomeProduto &field2= ValProduto}.
END PROCEDURE.









