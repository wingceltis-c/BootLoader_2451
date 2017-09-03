.text
.global init_led
.global bright_led
.global dark_led

#define GPCON                   0x56000000
#define GPDAT                   0x56000004
#define GPIO_OUT(GPIO)          (0x01<<(GPIO))
#define LED_1_GPIO              GPIO_OUT(25)
#define LED_2_GPIO              GPIO_OUT(26)
init_led:
        ldr r0,=GPCON
        ldr r1,[r0]
        bic r1,r1,#LED_1_GPIO
        bic r1,r1,#LED_2_GPIO
        str r1,[r0]
        mov pc,lr

bright_led:
        ldr r0,=GPDAT
        ldr r1,[r0]
        bic r1,r1,#LED_1_GPIO
        bic r1,r1,#LED_2_GPIO
        str r1,[r0]
        mov pc,lr

dark_led:
        ldr r0,=GPDAT
        ldr r1,[r0]
        orr r1,r1,#LED_1_GPIO
        orr r1,r1,#LED_2_GPIO
        str r1,[r0]
        mov pc,lr

