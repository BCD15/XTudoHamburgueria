DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

DO WITH FRAME {&frame}:
    ASSIGN {&tab}.{&field1}:SENSITIVE = pEnable
           {&tab}.{&field2}:SENSITIVE = pEnable.
    &if  "{&field3}" <> "" &then
        ASSIGN {&tab}.{&field3}:SENSITIVE = pEnable.
    &endif.
    &if  "{&field4}" <> "" &then
        ASSIGN {&tab}.{&field4}:SENSITIVE = pEnable.
    &endif.
END.
