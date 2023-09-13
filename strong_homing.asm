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

check_mem_for_missile:
blrl
backup
lwz r5, 0x2c(r3) # get pointer to gobj user data into r5
lwz r6, 0x0(r5) # r6 has missile 1 address (starts at 0)
lwz r7, 0x4(r5) # r7 has missile 2 address (starts at 0)

load r8, 0x803fc420
lwz r9, 0x0(r8) # r9 contains latest item spawn

cmpw r6, r9
beq skip1

# missile homing function here
branchl r12, 0x80174338

skip1:
cmpw r7, r9
beq skip2

# missile homing function here
branchl r12, 0x80174338

skip2:
restore
blr

# # # # # # # # # # # # # # # # # # # # # 

end:
restore

lbz	r3, 0 (r31)
