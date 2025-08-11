DEFINE BUTTON btSave  LABEL "Salvar"    SIZE 14 BY 1.
DEFINE BUTTON btCanc  LABEL "Cancelar"  SIZE 14 BY 1 AUTO-ENDKEY.

DEFINE INPUT PARAMETER cAction AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER iLastCodp AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER phF1 AS HANDLE NO-UNDO.

DEFINE QUERY qItem FOR itens, produtos SCROLLING.

DEFINE BUFFER bItem FOR itens.
DEFINE BUFFER bProduto FOR produtos.

DEFINE FRAME fItem
    itens.CodProduto    COLON 20 produtos.NomeProduto NO-LABEL
    itens.NumQuantidade COLON 20    
    itens.ValTotal      COLON 20 SKIP(1)
    btSave              COLON 10
    btCanc              
    WITH SIDE-LABELS THREE-D SIZE 100 BY 10
         VIEW-AS DIALOG-BOX TITLE "Item".  

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







