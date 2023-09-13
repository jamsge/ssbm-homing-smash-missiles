# 80268b48
.include "./Common.s"

backup

mr r31, r3 
lwz r30, 0x2c(r31) # put entity data in r30
load r29, 0x803fc420 # area with free memory

lwz r27, 0x518(r30) # get pointer to owner player struct entity
lwz r27, 0x2c(r27) # get pointer to entity data
lbz r27, 0x0c(r27) # 0x0c is the player slot, 0 indexed
mulli r27, r27, 8 # shared address pointer + counter takes up 8 bytes
add r29, r27, r29 # offset free memory address by 8*zeroIndexedPlayerSlot
stw r30, 0x0(r29) # set shared mem to entity data of item


lwz r28, 0x4(r29) # get shared counter, alternates 0 and 1 on each. make one for each player?
cmpwi r28, 1
beq is1

is0:
li r27, 1
stw r27, 0x4(r29)
b end

is1:
li r27, 0
stw r27, 0x4(r29)
b end

end:

restore

lwz r0, 0x001c(sp)
