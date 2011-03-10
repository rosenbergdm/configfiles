                #################################################
                #################################################
                #                                               #
                #                  /etc/zshenv                  #
                #                                               #
                #################################################
                #################################################


# File:  /etc/zshenv
# Version: 2.0.0

###############################################################################
 
#  Created by William G. Scott on January 2, 2009.
#  Copyright (c) . All rights reserved.


#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
#    USA
#    
#    cf. URL:   http://www.fsf.org/licensing/licenses/gpl.html                 
#                                                                              
############################################################################## 
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
############################################################################## 
######################     Define the minimal $PATH        ################### 
############################################################################## 
                                                                               
#   This file is always read, even with zsh -f .                                 
#   Therefore this file should contain only directives that cannot be over-
#   ridden with zsh -f                                                                  
#                                                                            
#   Uncomment for debug                                                          
#   print "reading /etc/zshenv with $0"                                          
#                                                                            
#   Create the minimal $PATH and $MANPATH assignments:                           
                                                                               
    if [[ -x /usr/libexec/path_helper ]]; then                                 
        eval $(/usr/libexec/path_helper -s)                                    
    fi   
                                                                          
############################################################################## 
                                                                              
                                                                              
                                                                              
                                                                              
                                                                              
                                                                              
                                                                              
##############################################################################
########################       Define $ZDOT           ########################
##############################################################################

#   Uncomment to assign $ZDOT as appropriate                                    
#   ZDOT="/Library/init/zsh" ; export ZDOT                                      
#   otherwise, use the following assignment:                                    
                                                                                
    if [[ -z $ZDOT && -d "/Library/init/zsh" ]]; then                         
        ZDOT="/Library/init/zsh" ; export ZDOT  
    elif [[ -z $ZDOT && -d "$HOME/Library/init/zsh" ]]; then                         
	        ZDOT="$HOME/Library/init/zsh" ; export ZDOT                              
    elif [[ -d "/etc/zsh/init/zsh" ]]; then                                   
        ZDOT="/etc/zsh/init/zsh" ; export ZDOT                                
    fi    
                                                                        
##############################################################################









##############################################################################
#########################        zshenv.d           ##########################
##############################################################################

#   Put any additional directives for the systemwide zshenv in files within 
#   ${ZDOT}/zshenv.d
#   See ${ZDOT}/zshenv.d/README for additional information. In general, you 
#   shouldn't need to add in anything.

    if [[ -d "${ZDOT}/zshenv.d" ]]; then
        foreach file in $(command ls ${ZDOT}/zshenv.d/* | grep -v disabled | grep -v README )
            source $file
        end
    fi

##############################################################################





# The user's own directives can be put into ~/.zshenv






 