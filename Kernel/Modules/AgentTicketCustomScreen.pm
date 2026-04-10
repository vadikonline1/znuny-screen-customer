# --
# Kernel/Modules/AgentTicketCustomScreen.pm - Custom ticket creation screen
# Copyright (C) 2024 Your Name
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

    # Alocați memoria pentru obiect
    my $Self = {};
    bless( $Self, $Type );

    # Verificați parametrii necesari
    for my $Needed (qw(ParamObject DBObject LayoutObject ConfigObject LogObject)) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # Obțineți prefixul de configurare pentru acest ecran custom
    my $ConfigPrefix = 'Ticket::Frontend::AgentTicketCustomScreen';

    # Încărcați setările din SysConfig
    my $Config = $Self->{ConfigObject}->Get($ConfigPrefix);

    # Configurare fallback dacă nu există setări specifice
    if ( !$Config ) {
        $Config = $Self->{ConfigObject}->Get('Ticket::Frontend::AgentTicketPhone');
    }

    # Construiți parametrii pentru acțiunea comună
    my %ActionParam = (
        Config          => $Config,
        ConfigPrefix    => $ConfigPrefix,
        Action          => 'AgentTicketCustomScreen',
        Subaction       => $Self->{Subaction},
        LinkKey         => 'CustomTicket',
        LinkLabel       => 'Create Custom Ticket',
        FormID          => $Self->{ParamObject}->GetParam( Param => 'FormID' ),
        CustomerAutoCompleteSupport => 1,
        CustomerTicketAutoCompleteSupport => 1,
    );

    # Încărcați modulele necesare
    $Self->{LayoutObject}->Block(
        Name => 'Outfit',
        Data => {
            JSFile => [
                'Core.Agent.TicketAction.js',
                'Core.Agent.TicketPhone.js',
            ],
        },
    );

    # Inițializați TicketActionCommon
    if ( !$Self->{TicketActionCommon} ) {
        $Self->{TicketActionCommon} = Kernel::Modules::AgentTicketActionCommon->new(
            %{$Self},
            %ActionParam,
        );
    }

    # Executați și returnați rezultatul
    return $Self->{TicketActionCommon}->Run();
}

1;
