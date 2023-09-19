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


li r8, 0 # for comparisons with 0
li r31, 0 # counter for first and second missile

missile_func_begin:
lwz r11, 0x0(r7)
cmpw r11, r8
beq skip2
lwz r3, 0x0(r7)
lbz r4, 0xDD7(r3) # Homing missile is 0, super missile is 1
lwz r5, 0x10(r3) # Item type, 5F is missile
cmpwi r5, 0x5f # skip if not missile
bne skip2
cmpwi r4, 1 # skip if not super missile
bne skip2
lwz r16, 0x518(r3) # pointer to owner character data
lbz r20, 0x0C(r16) # get player slot index
cmpwi r20, 0
bne m2p2
m2p1: # this missile belongs to player 1
load r20, 0x80453F10 # load static address of p2
lwz r20, 0xB0(r20) # player entity struct
lwz r20, 0x2C(r20) # player character data
b m2endload
m2p2: # this missile belongs to player 2
load r20, 0x80453080 # load static address of p1
lwz r20, 0xB0(r20)
lwz r20, 0x2C(r20)
m2endload:
lfs f14, 0xB4(r20) # character y position
bl my_floats
mflr r25
lfs f15, 0x4(r25) # get missile target offset value
lfs f19, 0x8(r25) # get missile position increment
fadd f16, f15, f14 # f16 = target Y value
lfs f15, 0x8(r25) # get missile target offset value
lfs f17, 0x50(r3) # get missile y value
fcmpo cr0, f17, f16
blt cr0, m2addheight
bgt cr0, m2subheight
m2addheight:
fadd f17, f19, f17
stfs f17, 0x50(r3)
b skip2
m2subheight:
fsub f17, f17, f19
stfs f17, 0x50(r3)
skip2:

cmpwi r31, 0x1
beq missile_func_end
mr r7, r6
addi r31, r31, 0x1
bne missile_func_begin

missile_func_end:


restore
blr

my_floats:
blrl
.float 0 # 0x0 = 0
.float 10.0 # 0x4 - missile target offset value
.float 2 # 0x8 - speed

# # # # # # # # # # # # # # # # # # # # # 

end:
restore

lbz	r3, 0 (r31)

