USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
//botões frame pedido
DEFINE BUTTON btFirst LABEL "<<".
DEFINE BUTTON btBack  LABEL "<".
DEFINE BUTTON btNext  LABEL ">".
DEFINE BUTTON btLast  LABEL ">>".
DEFINE BUTTON btAdd   LABEL "Adicionar"     SIZE 14 BY 1.
DEFINE BUTTON btMod   LABEL "Modificar"     SIZE 14 BY 1.
DEFINE BUTTON btDel   LABEL "Deletar"       SIZE 14 BY 1.
DEFINE BUTTON btSave  LABEL "Salvar"        SIZE 14 BY 1.
DEFINE BUTTON btCanc  LABEL "Cancelar"      SIZE 14 BY 1.
DEFINE BUTTON btExp   LABEL "Exportar"      SIZE 14 BY 1.
DEFINE BUTTON btExit  LABEL "Sair"          SIZE 14 BY 1 AUTO-ENDKEY.
//botões browse item
DEFINE BUTTON btAddItem LABEL "Adicionar"   SIZE 14 BY 1.
DEFINE BUTTON btModItem LABEL "Modificar"   SIZE 14 BY 1.
DEFINE BUTTON btDelItem LABEL "Deletar"     SIZE 14 BY 1.
//botões frame item
DEFINE BUTTON btSaveItem  LABEL "Salvar"    SIZE 14 BY 1.
DEFINE BUTTON btCancItem  LABEL "Cancelar"  SIZE 14 BY 1 AUTO-ENDKEY.

/*DEFINE INPUT PARAMETER cAction AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER iLastCodp AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER phF1 AS HANDLE NO-UNDO.*/

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.
//DEFINE VARIABLE iCodPedido AS INTEGER NO-UNDO.
//query frame pedido
DEFINE QUERY qPedido FOR pedidos, clientes, cidades, itens, produtos SCROLLING.
//query frame item
DEFINE QUERY qItem FOR itens, produtos SCROLLING.
//buffer frame pedido
DEFINE BUFFER bPedidos FOR pedidos.
DEFINE BUFFER bCidades FOR cidades.
DEFINE BUFFER bClientes FOR clientes.
//buffer frame item
DEFINE BUFFER bItem FOR itens.
DEFINE BUFFER bProduto FOR produtos.

DEF BROWSE bItens QUERY qPedido DISPLAY
        itens.CodItem                          WIDTH-CHARS 7
        itens.CodProduto COLUMN-LABEL "Codigo" WIDTH-CHARS 10
        produtos.NomeProduto                   WIDTH-CHARS 25
        itens.NumQuantidade                    WIDTH-CHARS 14
        produtos.ValProduto                    WIDTH-CHARS 8
        itens.ValTotal   COLUMN-LABEL "Total"  WIDTH-CHARS 10
        WITH SEPARATORS 5 DOWN SIZE 83 BY 10.

DEFINE FRAME fPedido
    btFirst              AT 4
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
    pedidos.CodPedido    COLON 20 pedidos.dataPedido 
    pedidos.CodCliente   COLON 20 clientes.NomeCliente NO-LABELS
    clientes.CodEndereco COLON 20
    clientes.CodCidade   COLON 20 cidades.NomeCidade   NO-LABELS
    pedidos.observacao   COLON 20 SKIP(1)
    bItens               AT 4     SKIP(0.3)
    btAddItem AT 4
    btModItem 
    btDelItem
    WITH SIDE-LABELS THREE-D SIZE 140 BY 22
         VIEW-AS DIALOG-BOX TITLE "Pedidos".

DEFINE FRAME fItem
    itens.CodProduto    COLON 20 produtos.NomeProduto NO-LABEL
    itens.NumQuantidade COLON 20    
    itens.ValTotal      COLON 20 SKIP(1)
    btSave              COLON 10
    btCanc              
    WITH SIDE-LABELS THREE-D SIZE 100 BY 10
        VIEW-AS DIALOG-BOX TITLE "Item".

{C:/dados/movButtons.i &query=qPedido}

ON 'choose' OF btAdd DO:
    ASSIGN cAction = "add".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
      
    CLEAR FRAME fPedido.
    DISPLAY NEXT-VALUE(seqPedido) @ pedidos.CodPedido WITH FRAME fPedido.
END.

ON 'choose' OF btMod DO:
    ASSIGN cAction = "mod".
    RUN piEnableButtons (INPUT FALSE).
    RUN piEnableFields (INPUT TRUE).
   
    DISPLAY pedidos.CodPedido WITH FRAME fPedido.
    RUN piDisp.
END.

/* ON 'choose' OF btDel DO: 
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER bPedido FOR pedidos.
    
    MESSAGE "Confirma a exclusão da cidade" pedidos.CodPedido "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Exclusão".
    IF  lConf THEN DO:
        FIND bPedido
            WHERE bPedido.CodPedido = pedidos.CodPedido
            EXCLUSIVE-LOCK NO-ERROR.
        IF  AVAILABLE bPedido THEN DO:
            IF NOT CAN-FIND(pedidos WHERE pedidos.CodPedido = bPedido.CodPedido) THEN DO:
                DELETE bPedido.
                RUN piOpenQuery.  
                GET PREV qPedido.
                RUN piDisp.
            END.
            ELSE DO:
                MESSAGE "Pedido possui pedidos associados e não pode ser excluida"
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.
        END.
    END.
END. */  

ON 'choose' OF btSave DO:
   DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.

   RUN piValCliente(INPUT pedidos.CodCliente:SCREEN-VALUE, OUTPUT lValid).
   IF  lValid = NO THEN DO:
       RETURN NO-APPLY.
   END.
   
   IF cAction = "add" THEN DO:
        CREATE bPedidos.
        ASSIGN bPedidos.CodPedido = INPUT pedidos.CodPedido.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bPedidos
            WHERE bPedidos.CodPedido = pedidos.CodPedido
            EXCLUSIVE-LOCK NO-ERROR.
   END.
   
   ASSIGN bPedidos.CodPedido  = INPUT FRAME fPedido:pedidos.CodPedido.
          bPedidos.CodCliente = INPUT FRAME fPedido:pedidos.CodCliente.
          bPedidos.DataPedido = INPUT FRAME fPedido:pedidos.DataPedido.
          //bPedidos.ValPedido  = INPUT pedidos.ValPedido.
          bPedidos.observacao = INPUT FRAME fPedido:pedidos.observacao.
                                                            
   RUN piEnableButtons (INPUT TRUE).
   RUN piEnableFields (INPUT FALSE).
   RUN piOpenQuery.
END.

ON 'leave' OF pedidos.CodCliente DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    RUN piValCliente(INPUT pedidos.CodCliente:SCREEN-VALUE, OUTPUT lValid).
    IF  lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    
    FIND FIRST bClientes
        WHERE bClientes.CodCliente = INPUT pedidos.CodCliente
        NO-LOCK NO-ERROR.
    FIND FIRST bCidades
        WHERE bCidades.CodCidade = bClientes.CodCidade
        NO-LOCK NO-ERROR.
    
    DISPLAY bClientes.NomeCliente @ Clientes.NomeCliente 
            bCidades.CodCidade @ cidades.CodCidade
            WITH FRAME fPedido.            
END. 

ON 'choose' OF btCanc DO:
    RUN piEnableButtons (INPUT TRUE).
    RUN piEnableFields (INPUT FALSE).
    RUN piDisp.
END.

/* ON CHOOSE OF btExp DO:
// exportar para csv
    DEFINE VARIABLE cArqCsv AS CHARACTER NO-UNDO.
    ASSIGN cArqCsv = SESSION:TEMP-DIRECTORY + "xtudo.csv".
    OUTPUT TO VALUE(cArqCsv).
    FOR EACH pedidos NO-LOCK:
        PUT UNFORMATTED
            pedidos.CodPedido  ";" 
            pedidos.NomePedido ";"    
            pedidos.CodEndereco ";"
            pedidos.CodCidade   ";"
            pedidos.observacao  ";".
        PUT UNFORMATTED SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqCsv).
// exportar para JSON
    DEFINE VARIABLE cArqJSON AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE oObj     AS JsonObject NO-UNDO.
    DEFINE VARIABLE aPedidos AS JsonArray  NO-UNDO.
    
    ASSIGN cArqJSON = SESSION:TEMP-DIRECTORY + "xtudo.json".
    aPedidos = new JsonArray().
    FOR EACH pedidos NO-LOCK:
        oObj = new JsonObject().
        oObj:add("CodigoPedido", pedidos.CodPedido).
        oObj:add("Nome", pedidos.NomePedido).
        oObj:add("Endereco", pedidos.CodEndereco).
        oObj:add("Cidade", pedidos.CodCidade).
        oObj:add("Observacao", pedidos.observacao).
        aPedidos:add(oObj).
    END.
    aPedidos:WriteFile(INPUT cArqJSON, INPUT yes, INPUT "utf-8").
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArqJSON).
END. */

/*ON 'choose' OF btAddItem DO:
    RUN "C:/dados/itens.p"(INPUT "add", INPUT iCodPedido, THIS-PROCEDURE).
END.*/

RUN piOpenQuery.
RUN piEnableButtons(INPUT TRUE).
APPLY "choose" TO btFirst.
//VIEW FRAME fPedido.
//DISPLAY pedidos WITH FRAME fPedido.

WAIT-FOR WINDOW-CLOSE OF FRAME fPedido.

PROCEDURE piDisp:
    IF AVAILABLE pedidos THEN DO:
        DISPLAY pedidos.CodPedido pedidos.dataPedido
                clientes.CodCliente clientes.NomeCliente clientes.CodEndereco clientes.CodCidade
                cidades.NomeCidade pedidos.observacao
            WITH FRAME fPedido.            
    END.
    ELSE DO:
        CLEAR FRAME fPedido.
        ASSIGN pedidos.observacao:SCREEN-VALUE IN FRAME fPedido = "".
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF  AVAILABLE pedidos THEN DO:
        ASSIGN rRecord = ROWID(pedidos).
    END.
    
    OPEN QUERY qPedido 
        FOR EACH pedidos,
           FIRST clientes WHERE clientes.CodCliente = pedidos.CodCliente,
           FIRST cidades  WHERE cidades.CodCidade  = clientes.CodCidade,
           FIRST itens    WHERE itens.CodPedido = pedidos.CodPedido,
           FIRST produtos WHERE produtos.CodProduto  = itens.CodProduto.
    REPOSITION qPedido TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piEnableButtons:
    {c:/dados/enableButtons.i &tab=pedidos &frame=fPedido}.
END PROCEDURE.

PROCEDURE piEnableFields:
    {c:/dados/enableFields.i &frame=fPedido &tab=pedidos &field1=dataPedido &field2=CodCliente &field3=observacao}.
END PROCEDURE.

PROCEDURE piValCliente:
    DEFINE INPUT PARAMETER pCliente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
  
    FIND FIRST bClientes
        WHERE bClientes.CodCliente = pCliente
        NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE bClientes THEN DO:
        MESSAGE "Cliente" pCliente "nao existe!!!"
                VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.



///////////////////////////// item

/* 

ON 'choose' OF btSave DO:
   DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.

   RUN piValProduto(INPUT itens.CodProduto:SCREEN-VALUE, OUTPUT lValid).
   IF  lValid = NO THEN DO:
       RETURN NO-APPLY.
   END.
   
   IF cAction = "add" THEN DO:
        CREATE bItem.
        
        DEF VAR iLastCodi AS INTEGER NO-UNDO.    
        ASSIGN bItem.CodPedido = iLastCodp.
     
        FOR FIRST itens NO-LOCK
            WHERE itens.CodPedido = bItem.CodPedido
            BY itens.CodItem DESCENDING:
            ASSIGN iLastCodi = itens.CodItem.
            LEAVE.
        END.
        
        ASSIGN bItem.CodItem = iLastCodi + 1.
   END.
   /*IF  cAction = "mod" THEN DO:
       FIND FIRST bCliente
            WHERE bCliente.CodCliente = clientes.CodCliente
            EXCLUSIVE-LOCK NO-ERROR.
   END.*/
   
   ASSIGN bItem.CodProduto    = INPUT itens.CodProduto.
          bItem.NumQuantidade = INPUT itens.NumQuantidade.
          bItem.ValTotal      = INPUT itens.ValTotal.
   
   RUN piOpenQuery IN phF1.
   RUN piDisp      IN phF1.
      
   APPLY "CLOSE" TO THIS-PROCEDURE.   
END.

ON 'leave' OF itens.CodProduto DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    RUN piValProduto(INPUT itens.CodProduto:SCREEN-VALUE, OUTPUT lValid).
    IF  lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY bProduto.NomeProduto @ produtos.NomeProduto WITH FRAME fItem.
END.

/*IF  cAction = "mod" THEN DO:
    RUN piOpenQuery.
    RUN piDisp.
END.*/

RUN piEnable.
VIEW FRAME fItem.
//DISPLAY clientes WITH FRAME fItem.

WAIT-FOR WINDOW-CLOSE OF FRAME fItem.

PROCEDURE piEnable:
    DO WITH FRAME fItem:
        ASSIGN btSave:SENSITIVE = TRUE.
               btCanc:SENSITIVE = TRUE.
               itens.CodProduto:SENSITIVE = TRUE.
               itens.NumQuantidade:SENSITIVE = TRUE.   
               itens.ValTotal:SENSITIVE = TRUE.
    END.
END PROCEDURE.

PROCEDURE piValProduto:
    DEFINE INPUT PARAMETER pProduto AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
  
    FIND FIRST bProduto
        WHERE bProduto.CodProduto = pProduto
        NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE bProduto THEN DO:
        MESSAGE "Produto" pProduto "nao existe!!!"
                VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.

/*PROCEDURE piDisp:
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
END PROCEDURE.*/

 */













