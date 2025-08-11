DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

DEFINE BUFFER bCheck FOR {&tab}.

DO WITH FRAME {&frame}:
    ASSIGN
        btFirst:SENSITIVE = pEnable
        btBack :SENSITIVE = pEnable
        btNext :SENSITIVE = pEnable
        btLast :SENSITIVE = pEnable
        btExit :SENSITIVE = pEnable
        btAdd  :SENSITIVE = pEnable
        btMod  :SENSITIVE = pEnable
        btDel  :SENSITIVE = pEnable
        btExp  :SENSITIVE = pEnable
        btSave :SENSITIVE = NOT pEnable
        btCanc :SENSITIVE = NOT pEnable.
        
        &if "{&frame}" = "fPedido" &then
            btAddItem:SENSITIVE = NOT pEnable.
            btModItem:SENSITIVE = NOT pEnable.
            btDelItem:SENSITIVE = NOT pEnable.
        &endif.

        FIND FIRST bCheck NO-LOCK NO-ERROR.
        IF AVAILABLE bCheck AND ROWID(bCheck) = ROWID({&tab}) THEN DO:
            btFirst:SENSITIVE = FALSE.
            btBack :SENSITIVE = FALSE.
        END.
        
        FIND LAST bCheck NO-LOCK NO-ERROR.
        IF AVAILABLE bCheck AND ROWID(bCheck) = ROWID({&tab}) THEN DO:
            btNext:SENSITIVE = FALSE.
            btLast:SENSITIVE = FALSE.
        END.
END.
