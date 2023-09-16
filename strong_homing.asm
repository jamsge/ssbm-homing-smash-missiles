# 8016e9a8

.include "./Common.s"

backup

li r3, 21 # GOBJ_CLASS_DEV_TEXT
li r4, 24 # GOBJ_PLINK_DEV_TEXT
li r5, 0 # priority
branchl r12, GObj_Create
mr r31, r3 # gobj pointer gets put into r31

li r3, 24 #data size # memory allocation size
branchl r12, HSD_MemAlloc
mr r30, r3 # pointer to allocated memory at r30

li r29, 0x0
stw r29, 0x0(r30) # missile 1 address
stw r29, 0x4(r30) # missile 2 address

mr r3, r31 # gobj
li r4, 0 # data_kind, ?
load r5, HSD_Free # destructor
mr r6, r30 # data
branchl r12, GObj_AddUserData

mr r3, r31 # gobj as first argument
bl check_mem_for_missile # the function that will run every frame
mflr r4 # callback
li r5, 20 # priority
branchl r12, GObj_AddProc

load r28, 0x803fc420
li r27, 0
stw r27, 0x0(r28) # set shared mem to 0
stw r27, 0x4(r28) # set shared counter to 0
stw r27, 0x8(r28) # set shared mem to 0
stw r27, 0xC(r28) # set shared counter to 0


b end
 
# # # # # # # # # # # # # # # # # # # # # 

# 80669fb4, (8066a00c), 81 1E 23 B4 = homing miss dat, 
check_mem_for_missile:
blrl
backup
lwz r5, 0x2c(r3) # get pointer to gobj user data into r5
mr r6, r5 # r6 has missile 1 address (starts at 0)
addi r5, r5, 0x4
mr r7, r5 # r7 has missile 2 address (starts at 0)

load r8, 0x803fc420 # TODO: NEED TO OFFSET THIS BY 8*zeroIndexedPlayerSlot (or just do it twice via loop and offset it the second time?)
lwz r9, 0x0(r8) # r9 contains latest item spawn
lwz r10, 0x4(r8) # r10 contains 0 or 1 denoting whether to use missile 1 or 2

cmpwi r10, 1
beq stwmissile1
stwmissile0:
stw r9, 0x0(r6)
b skip
stwmissile1:
stw r9, 0x0(r7)
skip:

# Below changes x vel and x position to 0. Why doesn't it work?????
li r8, 0
lwz r11, 0x0(r6)
cmpw r11, r8
beq skip1
lwz r3, 0x0(r6)
lbz r4, 0xDD7(r3) # Homing missile is 0, super missile is 1
lwz r5, 0x10(r3) # Item type, 5F is missile
cmpwi r4, 1
bne skip1
cmpwi r5, 0x5f
bne skip1
# below should be the homing logic
stw r8, 0x40(r3)
stw r8, 0x4c(r3)
skip1:

lwz r11, 0x0(r7)
cmpw r11, r8
beq skip2
lwz r3, 0x0(r7)
lbz r4, 0xDD7(r3) # Homing missile is 0, super missile is 1
lwz r5, 0x10(r3) # Item type, 5F is missile
cmpwi r4, 1
bne skip2
cmpwi r5, 0x5f
bne skip2
stw r8, 0x40(r3)
stw r8, 0x4c(r3)
skip2:


restore
blr

# # # # # # # # # # # # # # # # # # # # # 

end:
restore

lbz	r3, 0 (r31)
