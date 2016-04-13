package Fake;

=for ruby

describe Scientist::Experiment do
  class Fake
    include Scientist::Experiment

    def initialize(*args)
    end

    def enabled?
      true
    end

    attr_reader :published_result

    def exceptions
      @exceptions ||= []
    end

    def raised(op, exception)
      exceptions << [op, exception]
    end

    def publish(result)
      @published_result = result
    end
  end

=cut

use parent 'Scientist';
use Moo;
use Types::Standard qw/ArrayRef/;

# sub initialize {} # unimplemented

sub enabled { 1 }

has published_result => (
    is  => 'rw',
);

has exceptions => (
    is      => 'rw',
    isa     => ArrayRef[ArrayRef],
    builder => 1,
);

sub _build_exceptions { [[]] }

sub raised {
    my ($self, $op, $exception) = @_;
    push @{ $self->exceptions }, [$op, $exception];
}

sub publish {
    my ($self, $result) = @_;
    $self->published_result($result);
}

1;
