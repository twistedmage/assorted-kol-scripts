# -*- coding: utf-8 -*-
"""
Created on Wed Dec 17 12:01:14 2014

@author: Simon
"""
import itertools

class bot_skill:
    def __init__(self, pow_attack=0, blam=0, zap=0, run=0, roll=0,
                 hover=0, lube=0, shield=0, light=0):
        self.pow_attack = pow_attack
        self.blam = blam
        self.zap = zap
        self.run = run
        self.roll = roll
        self.hover = hover
        self.lube = lube
        self.shield = shield
        self.light = light

class bot_piece:
    def __init__(self, ID, slot, pow_attack=0, blam=0, zap=0, run=0, roll=0,
                 hover=0, lube=0, shield=0, light=0):
        self.ID = ID
        self.slot = slot
        self.bs = bot_skill(pow_attack, blam, zap, run, roll, hover, lube, shield, light)

class adv:
    def __init__(self, name, choices,  elf_items=[], schematics=[]):
        self.name = name
        self.choices = choices
        self.elf_items=elf_items
        self.schematics=schematics


def piece_quality(new_gear, advs):
    dmg=0
    elf_items=0
    schematics=0
    for adv in advs:
        if <lowest damage, highest elf item, highest schem>:
            new_advs_unsolved.append(adv)
            
    return dmg,elf_items,schematics
    
    
def best_piece_for_slot(slot_pieces, prev_gear, advs_unsolved):
    best_piece=pieces[0]
    best_dmg=1000
    best_elf_items=0
    best_schematics=0
    for piece in slot_pieces:
        new_dmg,new_elf_items,new_schematics = piece_quality(piece+prev_gear, advs_unsolved)
        if (new_dmg < best_dmg) or (new_dmg==best_dmg and new_elf_items > best_elf_items) or \
           (new_dmg==best_dmg and new_elf_items==best_elf_items and new_schematics>best_schematics) or :
            best_piece = piece
            best_dmg = new_dmg
            best_elf_items = new_elf_items
            best_schematics = new_schematics
    
    return best_piece, best_dmg, best_elf_items, best_schematics
    
    
def try_permutations(all_pieces, advs):
    best_pieces=[]
    best_dmg=1000
    best_elf_items=0
    best_schematics=0
    for perm in itertools.permutations(all_pieces):
        advs_unsolved = advs
        new_pieces = []
        for slot_pieces in perm:
            best_piece, new_dmg,new_elf_items,new_schematics = best_piece_for_slot(slot_pieces, advs_unsolved)
            new_pieces.append(best_piece)
        
        if (new_dmg < best_dmg) or (new_dmg==best_dmg and new_elf_items > best_elf_items) or \
           (new_dmg==best_dmg and new_elf_items==best_elf_items and new_schematics>best_schematics) or :
            best_advs = advs_unsolved
            best_pieces=new_pieces
    
    print("Best set left ", len(best_advs), "of", len(advs), "adventures unsolved")
    print(best_pieces);
    
    
def get_all_pieces():
    left=[]
    left.append(bot_piece(5, "left", pow_attack=2)  # mega vise
    left.append(bot_piece(4, "left", pow_attack=1, zap=1)  # rivet shocker
    left.append(bot_piece(3, "left", blam=1)  # rodent gun
    left.append(bot_piece(2, "left", zap=1, shield=1)  # bug zapper
    left.append(bot_piece(1, "left", pow_attack=1)  # tiny fist
    
    right=[]
    right.append(bot_piece(3, "right", pow_attack=1, shield=1)  # Wrecking Bal
    right.append(bot_piece(2, "right", zap=1)  # Power Arm
    right.append(bot_piece(1, "right", blam=1)  # Ball-Bearing Dispenser
 
    torso=[]
    torso.append(bot_piece(5, "torso", shield=3, light=1, blam=1)  # Military Chassis
    torso.append(bot_piece(4, "torso", shield=3, light=1)  # Security Chassis
    torso.append(bot_piece(3, "torso", shield=4)  # Big Head
    torso.append(bot_piece(2, "torso", shield=3, blam=1)  # Gun Head	
    torso.append(bot_piece(1, "torso", shield=3)  # basic head

    propulsion=[]
    propulsion.append(bot_piece(4, "propulsion", run=1, roll=1)  # Rollerfeet
    propulsion.append(bot_piece(3, "propulsion", run=2)  # Tripod Legs
    propulsion.append(bot_piece(2, "propulsion", run=1, shield=1)  # Heavy-Duty Legs	
    propulsion.append(bot_piece(1, "propulsion", run=1)  # regular legs
    
    all_pieces=[left,right,torso,propulsion]
    return all_pieces
    

def level1():
    advs=[]
    # guardbots
    advs.append(adv("Bulkybot", [bot_skill(pow_attack=1), bot_skill(shield=1)]))
    advs.append(adv("Doorbot", [bot_skill(pow_attack=1), bot_skill(zap=1), bot_skill(shield=1)]))
    advs.append(adv("Mookbot", [bot_skill(pow_attack=1), bot_skill(blam=1), bot_skill(shield=1)]))
    advs.append(adv("Security Drone", [bot_skill(blam=1), bot_skill(zap=1), bot_skill(shield=1)]))
    advs.append(adv("Turretbot", [bot_skill(blam=1), bot_skill(shield=1)]))
    advs.append(adv("Zippybot", [bot_skill(zap=1), bot_skill(shield=1)]))
    # easy passages
    advs.append(adv("Conveyor, Convey Thyself", [bot_skill(blam=2), bot_skill(shield=1)]))
    advs.append(adv("Crate Expectations", [bot_skill(pow_attack=2), bot_skill(shield=2)]))
    advs.append(adv("Some People Call It A Giant Slingblade", [bot_skill(run=2), bot_skill(shield=1)]))
    advs.append(adv("Tin Door. Rusted.", [bot_skill(blam=2), bot_skill(lube=1), bot_skill(shield=2)]))
    advs.append(adv("The Monster Masher!", [bot_skill(zap=2), bot_skill(shield=1)]))
    advs.append(adv("War of Gears", [bot_skill(pow_attack=2), bot_skill(hover=1), bot_skill(shield=2)]))
    # reward rooms
    advs.append(adv("Inadequate Copy Room Security", [bot_skill()], schematics=[1] ))
    advs.append(adv("Locker Room", [bot_skill()], elf_items=[1] ))
    advs.append(adv("Office Space", [bot_skill(),bot_skill(pow_attack=2)], schematics=[0,1], elf_items=[1,0]))
    advs.append(adv("Paperchase", [bot_skill()], schematics=[1]))
    advs.append(adv("The Dark Closet Returns", [bot_skill(), bot_skill(light=1)], elf_items=[1,2]))
    advs.append(adv("The Dilemma", [bot_skill()], schematics=[1] ))
    advs.append(adv("The Unhurt Locker", [bot_skill()], elf_items=[1] ))
    # hard passageways
    advs.append(adv("Closing Time", [bot_skill(shield=2), bot_skill(run=2, shield=1)]))
    advs.append(adv("Down In Flames", [bot_skill(blam=2, shield=1), bot_skill(shield=2)]))
    advs.append(adv("Getting Your Bearings", [bot_skill(roll=1, shield=1), bot_skill(shield=2)]))
    advs.append(adv("Gone With The Wind", [bot_skill(pow_attack=2, shield=1), bot_skill(shield=2)]))
    
    
    
all_pieces = get_all_pieces()
advs=level1()
try_permutations(all_pieces,advs)
    