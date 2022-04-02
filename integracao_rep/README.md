# Integração REP

```
.
├── README.md
└── src
    └── IntegRep.prw

1 directory, 2 files
```

Está rotina gera um arquivo de texto com dados do Protheus para ser importado em qualquer REP, que atenda ao layout AFD disposto no Sistema de Registro Eletrônico de Ponto - SREP - Portaria MTE 1.510/2009.

Layout AFD:

| Matricula   | PIS         | Data de admissão | Nome        | Código do funcionário |
| ----------- | ----------- | ---------------- | ----------- | --------------------- |
| 20 posições | 14 posições | 8  posições      | 52 posições | 30 posições           |

;00000000000000011111;110011011110000000;1010997;GILMA PEREIRA DOS SANTOS                            ;ADM RESTAURANTE               ;