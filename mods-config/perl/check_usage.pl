#! usr/bin/perl -w

use strict;
# use ...
# This is very important!
use vars qw(%RAD_CHECK %RAD_REPLY);
use constant RLM_MODULE_OK=>2;
use constant RLM_MODULE_UPDATED=>8;
use constant RLM_MODULE_REJECT=>0;
use constant RLM_MODULE_NOOP=>7;

my @warnings = (0,50,80,100);
my $int_max = 4294967296;
my $used_data = $RAD_CHECK{'Used-Bytes'};
my $total_data = $RAD_CHECK{'Total-Bytes'};

sub authorize {
    #We will reply, depending on the usage
    #If Total-Bytes is larger than the 32-bit limit
    #we have to set a Gigaword attribute
    if(exists($RAD_CHECK{'Total-Bytes'})
       && exists($RAD_CHECK{'Used-Bytes'})){

	#set available bytes (what is left)
	$RAD_CHECK{'Avail-Bytes'} 
	= $RAD_CHECK{'Total-Bytes'}-$RAD_CHECK{'Used-Bytes'};
    }
    else{
	return RLM_MODULE_NOOP;
    }

    #Available date is less or equal is zero
    if($RAD_CHECK{'Avail-Bytes'} <= 0 ){

	$RAD_REPLY{'Reply-Message'} = "Maximum usage exceeded";
	return RLM_MODULE_REJECT;
    }

    #If the available data is greater and equal to 32-bit int
    if($RAD_CHECK{'Avail-Bytes'} >= $int_max){
	#Mikrotik's reply attributes
	$RAD_REPLY{'Mikrotik-Total-Limit'} = 
	    $RAD_CHECK{'Avail-Bytes'} % $int_max;
	$RAD_REPLY{'Mikrotik-Total-Limit-Gigawords'} = 
	    int($RAD_CHECK{'Avail-Bytes'} / $int_max );

        #Coova Chilli's reply attributes
	#$RAD_REPLY{'ChilliSpot-Max-Total-Octets'} 
	#= $RAD_CHECK{'Avail-Bytes'} % $int_max;
	#$RAD_REPLY{'ChilliSpot-Max-Total-Gigawords'} 
	#=int($RAD_CHECK{'Avail-Bytes'} / $int_max );
    }
    else{
	$RAD_REPLY{'Mikrotik-Total-Limit'} = $RAD_CHECK{'Avail-Bytes'};
	#$RAD_REPLY{'ChilliSpot-Max-Total-Octets'} = $RAD_CHECK{'Avail-Bytes'};
    }
    return RLM_MODULE_UPDATED;
}

