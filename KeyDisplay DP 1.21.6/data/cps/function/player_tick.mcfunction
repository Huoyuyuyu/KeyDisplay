
execute unless score @s cps.uid matches 0.. run function cps:create

scoreboard players operation temp cps.int = @s cps.uid
execute at @s as @e[type=item_display, tag=cps.main_item] if score @s cps.uid = temp cps.int run tp @s ~ ~ ~
