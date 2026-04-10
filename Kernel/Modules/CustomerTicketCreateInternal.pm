package Kernel::Modules::TicketCreateGeneric;

use strict;
use warnings;

sub Run {
    my ($Self, %Param) = @_;

    my $ConfigName = $Self->{ParamObject}->GetParam( Param => 'Config' ) || 'Default';

    my $ConfigAll = $Self->{ConfigObject}->Get('TicketCreateGeneric') || {};
    my $Config = $ConfigAll->{$ConfigName} || {};

    # Submit form
    if ( $Self->{ParamObject}->GetParam( Param => 'FormSubmit' ) ) {

        my $Title = $Self->{ParamObject}->GetParam( Param => 'Title' ) || '';
        my $Body  = $Self->{ParamObject}->GetParam( Param => 'Body' ) || '';

        my $TicketID = $Self->{TicketObject}->TicketCreate(
            Title        => $Title,
            Queue        => $Config->{Queue} || 'Raw',
            State        => 'new',
            Priority     => $Config->{Priority} || '3 normal',
            CustomerUser => $Self->{UserLogin},
            UserID       => 1,
        );

        return $Self->{LayoutObject}->Redirect(
            OP => "Action=AgentTicketZoom;TicketID=$TicketID",
        );
    }

    my $Output = $Self->{LayoutObject}->Header();

    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'TicketCreateGeneric',
        Data => {
            ConfigName => $ConfigName,
            Title      => $Config->{Title} || 'Ticket Create',
        },
    );

    $Output .= $Self->{LayoutObject}->Footer();

    return $Output;
}

1;
