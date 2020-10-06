START:
    # Seta os registradores de hora, minuto e segundo com zero.
	mov $0, %su
	mov $0, %sd
	mov $0, %mu
	mov $0, %md
	mov $0, %hu
	mov $0, %hd
    # Seta os registradores de hora_AMPM, minuto_AMPM e AM/PM.
    mov $2, %hu2
    mov $1, %hd2
    mov $12, %empty # Define um espaço vazio.
    mov $10, %ampm # 10 = A, 15 = P

MAIN:

SET_BASE:
    # Pega SW[0] e passa seu valor para %base.
    getio $0, %base
    # Se SW[0] = 0, usa o modelo hh:mm:ss.
    cmp $0, %base
    je DEFAULT
    # Se SW[0] = 1, usa o modelo hh:mm A/P.
    cmp $1, %base
    je AMPM

DEFAULT:
    # Passa os valores contidos nos registradores para o 
    # display hexadecimal de forma hh:mm:ss.
	display $14, %su
	display $15, %sd
	display $16, %mu
	display $17, %md
	display $18, %hu
	display $19, %hd
    jmp NEED_CONFIG

AMPM:
    # Caso contrário, passa os valores contidos nos registradores para o 
    # display hexadecimal de forma hh:mm A/P.
	display $14, %ampm
	display $15, %empty
	display $16, %mu
	display $17, %md
	display $18, %hu
	display $19, %hd
    jmp NEED_CONFIG

NEED_CONFIG:
    # Pega SW[2] e passa seu valor para %config.
    getio $2, %config
    # Se SW[2] = 1, vai para a configuração do relógio
    cmp $1, %config
    je CONFIG
    #checa se passa 1 segundo
    getio $X, %time
    cmp $1, %time
    je SU

SU:
    #reset do time
    mov $0, %time
    # Checa se a unidade dos segundos vale 9.
    cmp $9, %su
    # Se verdadeiro pula para a checagem da casa das dezenas de segundo.
    je SD
    # Caso contrário, incrementa a unidade de segundo e reinicia o loop 
    # principal.
    add $1, %su
    jmp MAIN

SD:
    # Zera a unidade de segundo.
    mov $0, %su
    # Checa se a dezena dos segundos vale 5.
    cmp $5, %sd
    # Se verdadeiro pula para a checagem da casa das unidades de minuto.
    je MU
    # Caso contrário, incrementa a dezena de segundo e reinicia o loop 
    # principal.
    add $1, %sd
    jmp MAIN

MU:
    # Zera a dezena de segundo.
    mov $0, %sd
    # Checa se a unidade dos minutos vale 9.
    cmp $9, %mu
    # Se verdadeiro pula para a checagem da casa das dezenas de minuto.
    je MD
    # Caso contrário, incrementa a unidade de minuto e reinicia o loop 
    # principal.
    add $1, %mu
    jmp MAIN

MD:
    # Zera a unidade de minuto.
    mov $0, %mu
    # Checa se a dezena dos minutos vale 5.
    cmp $5, %md
    # Se verdadeiro pula para a checagem da casa das unidades de hora.
    je HU
    # Caso contrário, incrementa a dezena de minuto e reinicia o loop 
    # principal.
    add $1, %md
    jmp MAIN

HU:
    # Zera a dezena de minuto.
    mov $0, %md
    cmp $1, %hu2
    je AMPM_CHECK_HD11
    cmp $2, %hu2
    je AMPM_CHECK_HD12
    jmp HU2

AMPM_CHECK_HD11:
    cmp $1, %hd2
    je AMPM_CHECK_AP11
    add $1, %hu2
    jmp HU_P2

AMPM_CHECK_HD12:
    cmp $1, %hd2
    je AMPM_CHECK_AP12
    add $1, %hu2
    jmp HU_P2

AMPM_CHECK_AP11:
    cmp $15, %ampm
    je START
    add $1, %hu2
    mov $15, %ampm
    jmp HU_P2

AMPM_CHECK_AP12:
    cmp $15, %ampm
    je START
    mov $1, %hu2
    mov $0, %hd2
    mov $15, %ampm
    jmp HU_P2

HU2:
    cmp $9, %hu2
    je HD2
    add $1, %hu2
    jmp HU_P2

HD2:
    mov $0, %hu2
    add $1, hd%

HU_P2:
    # Checa se a unidade das horas vale 9.
    cmp $9, %hu
    # Se verdadeiro pula para o incremento da casa das dezenas de hora.
    je HD
    # Caso contrário, incrementa a unidade de hora e reinicia o loop principal.
    add $1, %hu
    jmp MAIN

HD:
    # Zera a unidade de hora.
    mov $0, %hu
    # Incrementa a unidade de hora e reinicia o loop principal.
    add $1, %hd
    jmp MAIN

CONFIG:
KEY0:
    getio $10, %key0
    cmp $0, %key0
    je SET_MU

KEY1:
    getio $11, %key1
    cmp $0, %key1
    je SET_MD

KEY2:
    getio $12, %key2
    cmp $0, %key2
    je SET_HU

KEY3:
    getio $13, %key3
    cmp $0, %key3
    je SET_HD
    jmp MAIN

SET_HD:
    cmp $2, %hd
    je RST_HD
    add $1, %hd

SET_HD2:
    cmp $1, %hd2
    je RST_HD2
    add $1, %hd2
    jmp MAIN

RST_HD:
    mov $0, %hd
    jmp SET_HD2

RST_HD2:
    sub $1, %hd2
    cmp $15, %ampm
    je TURN_AM
    jmp TURN_PM

TURN_AM:
    mov $10, %ampm
    jmp MAIN

TURN_PM:
    mov $15, %ampm
    jmp MAIN

SET_HU:
    cmp $9, %hu
    je RST_HU
    cmp $3, %hu
    je CHECK_END
    add $1, %hu

SET_HU2:
    cmp $9, %hu2
    je RST_HU2
    cmp $2, %hu2
    je CHECK_END2
    add $1, %hu2
    jmp MAIN

CHECK_END:
    cmp $2, %hd
    je RST_HU
    add $1, %hu
    jmp SET_HU2

CHECK_END2:
    cmp $1, %hd2
    je RST_HU
    add $1, %hu2
    jmp MAIN

RST_HU:
    mov $0, %hu
    jmp SET_HU2

RST_HU2:
    mov $1, %hu2
    jmp MAIN

SET_MD:
    cmp $5, %md
    je RST_MD
    add $1, %md
    jmp MAIN

RST_MD:
    mov $0, %md
    jmp MAIN

SET_MU:
    cmp $9, %mu
    je RST_MU
    add $1, %mu
    jmp MAIN

RST_MU:
    mov $0, %mu
    jmp MAIN