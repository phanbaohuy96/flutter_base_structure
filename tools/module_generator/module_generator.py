
from definations import *

from common_generator import generateCommonModule
from listing_generator import generateListingModule

if __name__ == "__main__":
    menu = {
        MenuItem.CommonModuleGenerator.value: 'Generate common module',
        MenuItem.ListingModuleGenerator.value: 'Generate listing module',
        MenuItem.Exit.value: "Exit"
    }

    while True: 
        options = menu.keys()
        for entry in options: 
            print(entry + '. ' + menu[entry])

        selection= input("Please Select: ") 
        if selection == MenuItem.CommonModuleGenerator.value: 
            generateCommonModule()
            break
        elif selection == MenuItem.ListingModuleGenerator.value: 
            generateListingModule()
            break
        elif selection == MenuItem.Exit.value: 
            break
        else: 
            print("Unknown Option Selected!")