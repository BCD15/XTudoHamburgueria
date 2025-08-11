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

DEFINE QUERY qCidade FOR cidades.

DEFINE BUFFER bCidade FOR cidades.

DEFINE FRAME fCidade
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
    cidades.CodCidade  COLON 20 
    cidades.NomeCidade COLON 20    
    cidades.CodUF      COLON 20
    WITH SIDE-LABELS THREE-D SIZE 140 BY 15
         VIEW-AS DIALOG-BOX TITLE "Cidades".

{C:/dados/movButtons.i &query=qCidade}

ON 'choose' OF btAdd DO:
    ASSIGN cAction = "add".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
   
    CLEAR FRAME fCidade.
    DISPLAY NEXT-VALUE(seqCidade) @ cidades.CodCidade WITH FRAME fCidade.
END.

ON 'choose' OF btMod DO:
    ASSIGN cAction = "mod".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
   
    DISPLAY cidades.CodCidade WITH FRAME fCidade.
    RUN piDisp.
END.

ON 'choose' OF btDel DO:  
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER bCidade FOR cidades.
    
    MESSAGE "Confirma a exclusão da cidade" cidades.CodCidade "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Exclusão".
    IF  lConf THEN DO:
        FIND bCidade
            WHERE bCidade.CodCidade = cidades.CodCidade
            EXCLUSIVE-LOCK NO-ERROR.
        IF  AVAILABLE bCidade THEN DO:
            IF NOT CAN-FIND(cliente WHERE cliente.CodCidade = bCidade.CodCidade) THEN DO:
                DELETE bCidade.
                RUN piOpenQuery.  
                GET PREV qCidade.
                RUN piDisp.
            END.
            ELSE DO:
                MESSAGE "Cidade possui clientes associados e não pode ser excluida"
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.
        END.
    END.
END.      

ON 'choose' OF btSave DO:
   IF cAction = "add" THEN DO:
        CREATE bCidade.
        ASSIGN bCidade.CodCidade  = INPUT cidades.CodCidade.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bCidade
            WHERE bCidade.CodCidade = cidades.CodCidade
            EXCLUSIVE-LOCK NO-ERROR.
   END.
   
   ASSIGN bCidade.NomeCidade = INPUT cidades.NomeCidade.
          bCidade.CodUF = INPUT cidades.CodUF.

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
    FOR EACH cidades NO-LOCK:
        PUT UNFORMATTED
            cidades.CodCidade  ";"
            cidades.NomeCidade ";"
            cidades.CodUF      ";".
        PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqCsv).
// exportar para JSON
    DEFINE VARIABLE cArqJSON AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE oObj     AS JsonObject NO-UNDO.
    DEFINE VARIABLE aCidades AS JsonArray  NO-UNDO.
    
    ASSIGN cArqJSON = SESSION:TEMP-DIRECTORY + "xtudo.json".
    aCidades = new JsonArray().
    FOR EACH cidades NO-LOCK:
        oObj = new JsonObject().
        oObj:add("CodigoCidade", cidades.CodCidade).
        oObj:add("Nome", cidades.NomeCidade).
        oObj:add("UF", cidades.CodUF).
        aCidades:add(oObj).
    END.
    aCidades:WriteFile(INPUT cArqJSON, INPUT yes, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqJSON).
END.

RUN piOpenQuery.
RUN piEnableButtons(INPUT TRUE).

IF AVAIL bCidade THEN DO: 
    APPLY "choose" TO btFirst.
END.
ELSE DO:
    APPLY "choose" TO btAdd.
END.


WAIT-FOR WINDOW-CLOSE OF FRAME fCidade.

PROCEDURE piDisp:
    IF AVAILABLE cidades THEN DO:
        DISPLAY cidades.CodCidade cidades.NomeCidade cidades.CodUF
             WITH FRAME fCidade.
    END.
    ELSE DO:
        CLEAR FRAME fCidade.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF  AVAILABLE cidades THEN DO:
        ASSIGN rRecord = ROWID(cidades).
    END.
    
    OPEN QUERY qCidade 
        FOR EACH cidades.
    
    GET FIRST qCidade.
END PROCEDURE.

PROCEDURE piEnableButtons:
    {c:/dados/enableButtons.i &tab=cidades &frame=fCidade}.
END PROCEDURE.

PROCEDURE piEnableFields:
    {c:/dados/enableFields.i &frame=fCidade &tab=cidades &field1= NomeCidade &field2= CodUF}.
END PROCEDURE.









