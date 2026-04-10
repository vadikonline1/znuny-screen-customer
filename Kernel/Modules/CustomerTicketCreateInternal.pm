package Kernel::Modules::CustomerTicketCreateInternal;

use strict;
use warnings;

sub Run {
    my ($Self, %Param) = @_;

    my %GetParam;

    # Formular submit
    if ( $Self->{ParamObject}->GetParam( Param => 'FormSubmit' ) ) {

        my $Title = $Self->{ParamObject}->GetParam( Param => 'Title' ) || '';
        my $Body  = $Self->{ParamObject}->GetParam( Param => 'Body' ) || '';

        my $TicketID = $Self->{TicketObject}->TicketCreate(
            Title        => $Title,
            Queue        => 'Raw',  # sau intern queue
            Lock         => 'unlock',
            Priority     => '3 normal',
            State        => 'new',
            CustomerUser => $Self->{UserLogin},
            OwnerID      => 1,
            UserID       => 1,
        );

        return $Self->{LayoutObject}->Redirect(
            OP => "Action=CustomerTicketZoom;TicketID=$TicketID",
        );
    }

    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'CustomerTicketCreateInternal',
        Data         => {},
    );
    $Output .= $Self->{LayoutObject}->Footer();

    return $Output;
}

1;
