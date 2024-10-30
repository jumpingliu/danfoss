import math
import random

COUNTER = 0

def sawtooth (current_value, increment, max_value):
    new_value = current_value + increment
    if (new_value >= max_value):
        new_value = 0
    return new_value

def step_sawtooth (current_value, increment, max_value):
    # To create the step effect, only increment the value when COUNTER is odd
    if (COUNTER % 2 ==  0): 
        return current_value
    return sawtooth(current_value, increment, max_value)

def sinwave (amplitude, offset, period):
    return int(math.sin(2 * math.pi * (1/period) * COUNTER) * amplitude) + offset 

def coswave (amplitude, offset, period):
    return int(math.cos(2 * math.pi * (1/period) * COUNTER) * amplitude) + offset

def set_initial(resources):

    #Readouts
    resources.get('u72_food_temp').set_value(-180)

    #Settings
    resources.get('r12_main_switch').set_value(1)
    resources.get('a13_highlim_air').set_value(400)
    resources.get('a14_lowlim_air').set_value(100)
    resources.get('d02_defstoptemp').set_value(-150)
    resources.get('minus_def_start').set_value(0)

    #Alarms

def update_values(resources):
    global COUNTER
    COUNTER += 1

    #Readouts
    resources.get('u20_s2_temp').set_value(random.randint(0,500))
    resources.get('u79_s2_temp_b').set_value(random.randint(1,500))
    resources.get('u88_s2_temp_c').set_value(random.randint(1,500))
    resources.get('u16_s4_air_temp').set_value(sinwave(200,300,30))
    resources.get('u76_s4_temp_b').set_value(random.randint(1,500))
    resources.get('u85_s4_temp_c').set_value(random.randint(1,500))
    resources.get('u23_akv_od_pc').set_value(random.randint(50,100))
    resources.get('u82_akv_od_pc_b').set_value(random.randint(50,100))
    resources.get('u91_akv_od_pc_c').set_value(random.randint(50,100))

    if (COUNTER % 10 == 0): 
        resources.get('minus_door_alarm').set_value(1)

    if (COUNTER % 20 == 0): 
        resources.get('minus_co2_alarm').set_value(1)

    if (COUNTER % 30 == 0): 
        resources.get('minus_refgleak').set_value(1)

    if (COUNTER % 60 == 0): 
        resources.get('minus_door_alarm').set_value(0)
        resources.get('minus_co2_alarm').set_value(0)
        resources.get('minus_refgleak').set_value(0)
