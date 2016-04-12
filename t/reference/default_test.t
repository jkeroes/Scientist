use Test2::Bundle::Extended -target => 'Scientist';

=for ruby

describe Scientist::Default do
  before do
    @ex = Scientist::Default.new "default"
  end

=cut

my $ex = $CLASS->new(experiment => 'default');

=for ruby

  it "is always enabled" do
    assert @ex.enabled?
  end

=cut

subtest 'is always enabled' => sub {
    my $ex = $CLASS->new(experiment => 'default');
    ok $ex->enabled, "default enabled() is true";
};

=for ruby

  it "noops publish" do
    assert_nil @ex.publish("data")
  end

=cut

subtest 'noops publish' => sub {
    my $ex = $CLASS->new(experiment => 'default');
    is [$ex->publish], [], "default publish() returns false";
};

=for ruby

  it "is an experiment" do
    assert Scientist::Default < Scientist::Experiment
  end

=cut

subtest 'is an experiment' => sub {
    todo scientist_experiment_namespace_unimplemented => sub {
        fail;
    };
};

=for ruby

  it "reraises when an internal action raises" do
     assert_raises RuntimeError do
       @ex.raised :publish, RuntimeError.new("kaboom")
     end
  end
end

=cut

subtest 'reraises when an internal action raises' => sub {
    my $mock = mock $CLASS => (
        override => [
            publish => sub {
                die "kaboom";
            },
        ],
    );

    my $ex = $CLASS->new(experiment => 'default');
    like(
        dies { $ex->publish },
        qr/kaboom/,
        'internal exceptions will die'
    );
};

done_testing;
