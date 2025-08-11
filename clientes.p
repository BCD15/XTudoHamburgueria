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

DEFINE QUERY qCliente FOR clientes, cidades SCROLLING.

DEFINE BUFFER bCliente FOR clientes.
DEFINE BUFFER bCidades FOR cidades.

DEFINE FRAME fCliente
    btFirst              AT 2
    btBack 
    btNext 
    btLast               SPACE(3)
    btAdd 
    btMod 
    btDel                SPACE(3)
    btSave 
    btCanc               SPACE(3)
    btExp                SPACE(4)
    btExit               SKIP(1) 
    clientes.CodCliente  COLON 20 
    clientes.NomeCliente COLON 20    
    clientes.CodEndereco COLON 20
    clientes.CodCidade   LABEL "Cidade" COLON 20 cidades.NomeCidade NO-LABELS
    clientes.observacao  COLON 20
    WITH SIDE-LABELS THREE-D SIZE 140 BY 15
         VIEW-AS DIALOG-BOX TITLE "Clientes".

{C:/dados/movButtons.i &query=qCliente}

ON 'choose' OF btAdd DO:
    ASSIGN cAction = "add".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
   
    CLEAR FRAME fCliente.
    DISPLAY NEXT-VALUE(seqCliente) @ clientes.CodCliente WITH FRAME fCliente.
END.

ON 'choose' OF btMod DO:
    ASSIGN cAction = "mod".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
   
    DISPLAY clientes.CodCliente WITH FRAME fCliente.
    RUN piDisp.
END.

ON 'choose' OF btDel DO: 
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER bCliente FOR clientes.
    
    MESSAGE "Confirma a exclusão da cidade" clientes.CodCliente "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Exclusão".
    IF  lConf THEN DO:
        FIND bCliente
            WHERE bCliente.CodCliente = clientes.CodCliente
            EXCLUSIVE-LOCK NO-ERROR.
        IF  AVAILABLE bCliente THEN DO:
            IF NOT CAN-FIND(pedidos WHERE pedidos.CodCliente = bCliente.CodCliente) THEN DO:
                DELETE bCliente.
                RUN piOpenQuery.  
                GET PREV qCliente.
                RUN piDisp.
            END.
            ELSE DO:
                MESSAGE "Cliente possui clientes associados e não pode ser excluida"
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.
        END.
    END.
END.   

ON 'choose' OF btSave DO:
   DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.

   RUN piValCidade(INPUT clientes.CodCidade:SCREEN-VALUE, OUTPUT lValid).
   IF  lValid = NO THEN DO:
       RETURN NO-APPLY.
   END.
   
   IF cAction = "add" THEN DO:
        CREATE bCliente.
        ASSIGN bCliente.CodCliente = INPUT clientes.CodCliente.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bCliente
            WHERE bCliente.CodCliente = clientes.CodCliente
            EXCLUSIVE-LOCK NO-ERROR.
   END.
   
   ASSIGN bCliente.NomeCliente = INPUT clientes.NomeCliente.
          bCliente.CodEndereco = INPUT clientes.CodEndereco.
          bCliente.CodCidade   = INPUT clientes.CodCidade.
          bCliente.observacao  = INPUT clientes.observacao.

   RUN piEnableButtons (INPUT TRUE).
   RUN piEnableFields (INPUT FALSE).
   RUN piOpenQuery.
END.

ON 'leave' OF clientes.CodCidade DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    RUN piValCidade(INPUT clientes.CodCidade:SCREEN-VALUE, OUTPUT lValid).
    IF  lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY bCidades.NomeCidade @ cidades.NomeCidade WITH FRAME fClientes.
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
    FOR EACH clientes NO-LOCK:
        PUT UNFORMATTED
            clientes.CodCliente  ";" 
            clientes.NomeCliente ";"    
            clientes.CodEndereco ";"
            clientes.CodCidade   ";"
            clientes.observacao  ";".
        PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqCsv).
// exportar para JSON
    DEFINE VARIABLE cArqJSON AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE oObj     AS JsonObject NO-UNDO.
    DEFINE VARIABLE aClientes AS JsonArray  NO-UNDO.
    
    ASSIGN cArqJSON = SESSION:TEMP-DIRECTORY + "xtudo.json".
    aClientes = new JsonArray().
    FOR EACH clientes NO-LOCK:
        oObj = new JsonObject().
        oObj:add("CodigoCliente", clientes.CodCliente).
        oObj:add("Nome", clientes.NomeCliente).
        oObj:add("Endereco", clientes.CodEndereco).
        oObj:add("Cidade", clientes.CodCidade).
        oObj:add("Observacao", clientes.observacao).
        aClientes:add(oObj).
    END.
    aClientes:WriteFile(INPUT cArqJSON, INPUT yes, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqJSON).
END.

RUN piOpenQuery.
RUN piEnableButtons(INPUT TRUE).
IF AVAIL clientes THEN DO: 
    APPLY "choose" TO btFirst.
END.
ELSE DO:
    APPLY "choose" TO btAdd.
END.

WAIT-FOR WINDOW-CLOSE OF FRAME fCliente.

PROCEDURE piDisp:
    IF AVAILABLE clientes THEN DO:
        DISPLAY clientes.CodCliente clientes.NomeCliente 
                clientes.CodEndereco clientes.CodCidade 
                cidades.NomeCidade clientes.observacao
             WITH FRAME fCliente.
    END.
    ELSE DO:
        CLEAR FRAME fCliente.
        ASSIGN clientes.observacao:SCREEN-VALUE IN FRAME fCliente = "".
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF  AVAILABLE clientes THEN DO:
        ASSIGN rRecord = ROWID(clientes).
    END.
    
    OPEN QUERY qCliente 
        FOR EACH clientes,
           FIRST cidades WHERE cidades.CodCidade = clientes.CodCidade.

    REPOSITION qCliente TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piEnableButtons:
    {c:/dados/enableButtons.i &tab=clientes &frame=fCliente}.
END PROCEDURE.

PROCEDURE piEnableFields:
    {c:/dados/enableFields.i &frame=fCliente &tab=clientes &field1=NomeCliente &field2=CodEndereco &field3=CodCidade &field4=observacao}.
END PROCEDURE.

PROCEDURE piValCidade:
    DEFINE INPUT PARAMETER pCidade AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
  
    FIND FIRST bCidades
        WHERE bCidades.CodCidade = pCidade
        NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE bCidades THEN DO:
        MESSAGE "Cidade" pCidade "nao existe!!!"
                VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.




