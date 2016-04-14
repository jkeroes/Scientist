package Scientist::Observation;

use strict;
use warnings;
# VERSION

use Moo;
use Time::HiRes qw/time/;
use Try::Tiny;
use Types::Standard qw/CodeRef InstanceOf Num Str Value/;
use namespace::clean;

# ABSTRACT: What happened when this named behavior was executed?

has experiment => (
    is       => 'ro',
    isa      => InstanceOf["Scientist"],
    required => 1,
);

has now => (
    is      => 'ro',
    isa     => Num,
    default => time(),
);

has name => (
    is      => 'ro',
    isa     => Str,
);

has value => (
    is  => 'rw',
    isa => Value,
);

has exception => (
    is  => 'rw',
    isa => Str,
);

has duration => (
    is  => 'rw',
    isa => Num,
);

has block => (
    is       => 'ro',
    isa      => CodeRef,
    required => 1,
);

sub BUILD {
    my ($self, $args) = @_;

    try {
        my $value = $self->block->();
        $self->value($value);
    }
    catch {
        $self->exception($_);
    };

    $self->duration(time() - $self->now);
}

sub cleaned_value {
    my ($self, $value) = @_;

    return unless $value;
    return $self->experiment->clean_value($value);
}

# Renamed from reference def: equivalent_to?
sub is_equivalent_to {
    my ($self, $other, $comparator) = @_;

    return unless $other->isa("Scientist::Observation");

    my $values_are_equal = 0;
    my $both_raised      =   $other->raised &&   $self->raised;
    my $neither_raised   = ! $other->raised && ! $self->raised;

    # TODO

=for ruby

    if neither_raised
      if block_given?
        values_are_equal = yield value, other.value
      else
        values_are_equal = value == other.value
      end
    end

    exceptions_are_equivalent = # backtraces will differ, natch
      both_raised &&
        other.exception.class == exception.class &&
          other.exception.message == exception.message

    (neither_raised && values_are_equal) ||
      (both_raised && exceptions_are_equivalent)

=cut
}

=for ruby

    [value, exception, self.class].compact.map(&:hash).inject(:^)

=cut

sub hash {
    # TODO
}

sub raised {
    my ($self) = @_;
    return !! $self->exception;
}

1;
