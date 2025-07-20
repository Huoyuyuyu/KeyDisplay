
execute store result score @s cps.uid run scoreboard players add uid_top cps.int 1

summon minecraft:item_display ~ ~ ~ {Tags:["cps.main_item","cps.temp"],item:{id:"minecraft:red_stained_glass",components:{item_model:"cps:main"}}}

scoreboard players operation @e[type=item_display, distance=..1, tag=cps.temp, limit=1] cps.uid = @s cps.uid

tag @e[type=item_display, distance=..1, tag=cps.temp, limit=1] remove cps.temp

