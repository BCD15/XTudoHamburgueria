ON 'choose' OF btFirst DO:
    GET FIRST {&query}.
    RUN piDisp.
    RUN piEnableButtons(INPUT TRUE).
END.

ON 'choose' OF btBack DO:
    GET PREV {&query}.
    RUN piDisp.
    RUN piEnableButtons(INPUT TRUE).
END.

ON 'choose' OF btNext DO:
    GET NEXT {&query}.
    RUN piDisp.
    RUN piEnableButtons(INPUT TRUE).
END.

ON 'choose' OF btLast DO:
    GET LAST {&query}.
    RUN piDisp.
    RUN piEnableButtons(INPUT TRUE).
END.
