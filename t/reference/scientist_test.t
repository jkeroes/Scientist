use Test2::Bundle::Extended -target => 'Scientist';

=begin ruby

describe Scientist do
  it "has a version or whatever" do
    assert Scientist::VERSION
  end

=cut

subtest "has a version or whatever" => sub {
    SKIP: {
        skip 'handled by dzil build';
        ok $CLASS::VERSION, "got version";
    };
};

=begin ruby

  it "provides a helper to instantiate and run experiments" do
    obj = Object.new
    obj.extend(Scientist)

    r = obj.science "test" do |e|
      e.use { :control }
      e.try { :candidate }
    end

    assert_equal :control, r
  end

=cut

subtest "provides a helper to instantiate and run experiments" => sub {
    my $e = $CLASS->new(
        experiment => 'test',
        use        => sub { 'control' },
        try        => sub { 'candidate' },
    );

    my $r = $e->run;

    is $r, 'control', 'run() returns use() output';
};

=begin ruby

  it "provides an empty default_scientist_context" do
    obj = Object.new
    obj.extend(Scientist)

    assert_equal Hash.new, obj.default_scientist_context
  end

=cut

subtest "provides an empty default_scientist_context" => sub {
    is $CLASS->new->context, {}, 'context defaults to {}';
};

=begin ruby

  it "respects default_scientist_context" do
    obj = Object.new
    obj.extend(Scientist)

    def obj.default_scientist_context
      { :default => true }
    end

    experiment = nil

    obj.science "test" do |e|
      experiment = e
      e.context :inline => true
      e.use { }
    end

    refute_nil experiment
    assert_equal true, experiment.context[:default]
    assert_equal true, experiment.context[:inline]
  end

=cut

subtest "respects default_scientist_context" => sub {
    subtest 'refute_nil experiment' => sub {
        like(
            dies { $CLASS->new(experiment => undef) },
            qr/./,
            'experiment must be a string'
        );
    };

    subtest 'default context' => sub {
        my $mock = mock $CLASS => (
            override => [
                _build_context => sub {
                    return { default => 1 };
                },
            ],
        );

        my $e = $CLASS->new;
        is $e->context->{default}, 1, 'got "subclassed" default context';
    };

    subtest 'inline context' => sub {
        my $e = $CLASS->new(
            context => { inline => 1 },
            use     => sub { },
        );

        is $e->context->{inline}, 1, 'got "inlined" context';
    };
};

=begin ruby

  it "runs the named test instead of the control" do
    obj = Object.new
    obj.extend(Scientist)

    result = obj.science "test", run: "first-way" do |e|
      experiment = e

      e.try("first-way") { true }
      e.try("second-way") { true }
    end

    assert_equal true, result
  end

=cut

subtest "runs the named test instead of the control" => sub {
    todo named_tests_unimplemented => sub {
        fail;
    };
};

=begin ruby

  it "runs control when there is a nil named test" do
    obj = Object.new
    obj.extend(Scientist)

    result = obj.science "test", nil do |e|
      experiment = e

      e.use { true }
      e.try("second-way") { true }
    end

    assert_equal true, result
  end
end

=cut

subtest "runs control when there is a nil named test" => sub {
    todo named_tests_unimplemented => sub {
        fail;
    };
};

done_testing;
