# --
# Kernel/Modules/AgentTicketCustomScreen.pm - Custom ticket creation screen
# Copyright (C) 2024 Your Company Name
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Modules::AgentTicketCustomScreen;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # Allocate memory for the object
    my $Self = {};
    bless( $Self, $Type );

    # Check needed objects
    for my $Needed (qw(ParamObject DBObject LayoutObject ConfigObject LogObject)) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # Get config prefix for this custom screen
    my $ConfigPrefix = 'Ticket::Frontend::AgentTicketCustomScreen';
    
    # Load configuration from SysConfig
    my $Config = $Self->{ConfigObject}->Get($ConfigPrefix);
    
    # Fallback to phone ticket config if no custom config exists
    if ( !$Config || !ref $Config ) {
        $Config = $Self->{ConfigObject}->Get('Ticket::Frontend::AgentTicketPhone');
    }
    
    # Get current subaction
    my $Subaction = $Self->{ParamObject}->GetParam( Param => 'Subaction' ) // '';
    
    # Build parameters for common ticket action
    my %ActionParam = (
        Config          => $Config,
        ConfigPrefix    => $ConfigPrefix,
        Action          => 'AgentTicketCustomScreen',
        Subaction       => $Subaction,
        LinkKey         => 'CustomTicket',
        LinkLabel       => 'Create Custom Ticket',
        FormID          => $Self->{ParamObject}->GetParam( Param => 'FormID' ),
        CustomerAutoCompleteSupport      => 1,
        CustomerTicketAutoCompleteSupport => 1,
    );
    
    # Add JavaScript files for the layout
    $Self->{LayoutObject}->Block(
        Name => 'Outfit',
        Data => {
            JSFile => [
                'Core.Agent.TicketAction.js',
                'Core.Agent.TicketPhone.js',
            ],
        },
    );
    
    # Initialize TicketActionCommon
    if ( !$Self->{TicketActionCommon} ) {
        $Self->{TicketActionCommon} = Kernel::Modules::AgentTicketActionCommon->new(
            %{$Self},
            %ActionParam,
        );
    }
    
    # Execute and return the result
    return $Self->{TicketActionCommon}->Run();
}

1;
