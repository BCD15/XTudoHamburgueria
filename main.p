DEFINE BUTTON btCidades     LABEL "Cidades"                SIZE 20 BY 1.
DEFINE BUTTON btProdutos    LABEL "Produtos"               SIZE 20 BY 1.
DEFINE BUTTON btClientes    LABEL "Clientes"               SIZE 20 BY 1.
DEFINE BUTTON btPedidos     LABEL "Pedidos"                SIZE 20 BY 1.
DEFINE BUTTON btExit        LABEL "Sair"                   SIZE 20 BY 1 AUTO-ENDKEY.
DEFINE BUTTON btRelClientes LABEL "Relatorio de Clientes"  SIZE 30 BY 1.
DEFINE BUTTON btRelPedidos  LABEL "Relatorio de Pedidos"   SIZE 30 BY 1.

DEFINE FRAME fMain
    btCidades     AT 3
    btProdutos 
    btClientes
    btPedidos
    btExit
    btRelClientes AT 3
    btRelPedidos
    WITH FRAME fMain THREE-D WIDTH 110 
        VIEW-AS DIALOG-BOX TITLE "Hamburgueria XTudo".

ON 'choose' OF btCidades DO:
    RUN C:/dados/cidades.p.
END.

ON 'choose' OF btProdutos DO:
    RUN C:/dados/produtos.p.
END.

ON 'choose' OF btClientes DO:
    RUN C:/dados/clientes.p.
END.

ON 'choose' OF btPedidos DO:
    RUN C:/dados/pedidos.p.
END.

ON 'choose' OF btRelClientes DO:
    RUN C:/dados/relClientes.p.
END.

ON 'choose' OF btRelPedidos DO:
    RUN C:/dados/relPedidos.p.
END.
                             
RUN piHabilitaButtons(INPUT TRUE).
DISPLAY WITH FRAME fMain.

WAIT-FOR WINDOW-CLOSE OF FRAME fMain.

PROCEDURE piHabilitaButtons:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

    DO WITH FRAME fMain:
       ASSIGN btCidades    :SENSITIVE = pEnable
              btProdutos   :SENSITIVE = pEnable
              btClientes   :SENSITIVE = pEnable
              btPedidos    :SENSITIVE = pEnable
              btExit       :SENSITIVE = pEnable
              btRelClientes:SENSITIVE = pEnable
              btRelPedidos :SENSITIVE = pEnable.
    END.
END PROCEDURE.

