package Scientist::Result;

use strict;
use warnings;
# VERSION

use Moo;
use List::MoreUtils qw/any none/;
use Scalar::Util qw/refaddr/;
use Types::Standard qw/ArrayRef InstanceOf Num Str Value/;
use namespace::clean;

# ABSTRACT: the immutable result of running an experiment

has control => (
    is  => 'ro',
    isa => InstanceOf["Scientist::Obervation"],
);

has experiment => (
    is  => 'ro',
    isa => InstanceOf["Scientist"],
);

has ignored => (
    is  => 'rw',
    isa => ArrayRef[InstanceOf["Scientist::Obervation"]],
);

has mismatched => (
    is  => 'rw',
    isa => ArrayRef[InstanceOf["Scientist::Obervation"]],
);

has observations => (
    is  => 'rw',
    isa => ArrayRef[InstanceOf["Scientist::Obervation"]],
);

sub candidates {
    my ($self) = @_;
    my $control_addr = refaddr($self->control);
    return grep { refaddr($_) ne $control_addr } @{ $self->observations };
}

sub context {
    my ($self) = @_;
    return $self->experiment->context;
}

sub experiment_name {
    my ($self) = @_;
    return $self->experiment->experiment;
}

sub has_matched {
    my ($self) = @_;
    return none { $self->mismatched } && ! $self->ignored;
}

# Renamed from reference def: mismatched?
sub has_mismatched {
    my ($self) = @_;
    return any { $self->mismatched };
}

# Renamed from reference def: mismatched?
sub has_ignored {
    my ($self) = @_;
    return any { $self->ignored };
}

sub BUILD {
    my ($self, $args) = @_;
    $self->evaluate_candidates;
}

sub evaluate_candidates {
    my ($self) = @_;

    my $control = $self->control;

    my @mismatched = grep {
        ! $self->experiment->observations_are_equivalent($control, $_)
    } @{ $self->candidates };

    my @ignored = grep {
        $self->experiment->ignore_mismatched_observation($control, $_)
    } @{ $self->candidates };

    $self->ignored(\@ignored);

    my %ignored_addrs = map { refaddr($_) => 1 } @ignored;

    # @mismatched set without @ignored set
    my @wanted = grep { ! $ignored_addrs{refaddr($_)} } @mismatched;

    $self->mismatched(@wanted);
}

1;
