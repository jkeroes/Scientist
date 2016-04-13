use Test2::Bundle::Extended -target => 'Scientist';

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Fake;
use Try::Tiny;

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

subtest describe_experiment => sub {

=for ruby

  before do
    @ex = Fake.new
  end

=cut

# will be done manually for each subtest.

=for ruby

  it "has a default implementation" do
    ex = Scientist::Experiment.new("hello")
    assert_kind_of Scientist::Default, ex
    assert_equal "hello", ex.name
  end

=cut

    subtest 'has a default implementation' => sub {
        ok my $ex = Fake->new(), 'Fake->new()';
    };

=for ruby

  it "provides a static default name" do
    assert_equal "experiment", Fake.new.name
  end

=cut

    subtest "provides a static default name" => sub {
        is(Fake->new->experiment,
            'experiment',
            'got default experiment() name()'
        );
    };

=for ruby

  it "requires includers to implement enabled?" do
    obj = Object.new
    obj.extend Scientist::Experiment

    assert_raises NoMethodError do
      obj.enabled?
    end
  end

=cut

    subtest "requires includers to implement enabled?" => sub {
        todo not_currently_required => sub {
            fail;
        };
    };

=for ruby

  it "requires includers to implement publish" do
    obj = Object.new
    obj.extend Scientist::Experiment

    assert_raises NoMethodError do
      obj.publish("result")
    end
  end

=cut

    subtest "requires includers to implement publish" => sub {
        todo not_currently_required => sub {
            fail;
        };
    };

=for ruby

  it "can't be run without a control behavior" do
    e = assert_raises Scientist::BehaviorMissing do
      @ex.run
    end

    assert_equal "control", e.name
  end

=cut

    subtest "can't be run without a control behavior" => sub {
        # XXX This is not a very good error message.
        like(
            dies { $CLASS->new->run },
            qr/Can't use an undefined value as a subroutine reference/,
            "dies without a control sub"
        );
    };

=for ruby

  it "is a straight pass-through with only a control behavior" do
    @ex.use { "control" }
    assert_equal "control", @ex.run
  end

=cut

    subtest "is a straight pass-through with only a control behavior" => sub {
        my $ex = Fake->new(use => sub { 'control' });
        is $ex->run, 'control', 'run() returns control()';
    };

=for ruby

  it "runs other behaviors but always returns the control" do
    @ex.use { "control" }
    @ex.try { "candidate" }

    assert_equal "control", @ex.run
  end

=cut

    subtest "runs other behaviors but always returns the control" => sub {
        my $ex = Fake->new(
            use => sub { 'control' },
            try => sub { 'candidate' },
        );

        is(
            $ex->run,
            'control',
            'run() returns control() even with defined candidate()'
        );
    };

=for ruby

  it "complains about duplicate behavior names" do
    @ex.use { "control" }

    e = assert_raises Scientist::BehaviorNotUnique do
      @ex.use { "control-again" }
    end

    assert_equal @ex, e.experiment
    assert_equal "control", e.name
  end

=cut

    subtest "complains about duplicate behavior names" => sub {
        my $ex = Fake->new(use => sub { 'control' });

        todo BehaviorNotUnique_exception_unimplemented => sub {
            ok(
                dies { $ex->use( sub { 'control-again' } ) },
                "can't overwrite use()"
            );
            my ($exception) = $ex->exceptions;

            # is($ex->experiment,
            #     $exception->{experiment},
            #     "The exception had our experiment's name"
            # );

            # is($exception->{name},
            #     'control',
            #     "The exception's name is 'control'"
            # );
        };
    };

=for ruby

  it "swallows exceptions raised by candidate behaviors" do
    @ex.use { "control" }
    @ex.try { raise "candidate" }

    assert_equal "control", @ex.run
  end

=cut

    subtest "swallows exceptions raised by candidate behaviors" => sub {
        my $ex = Fake->new(
            use => sub { 'control' },
            try => sub { die 'candidate' },
        );

        my $result;
        ok(
            lives { $result = $ex->run },
            'catches exceptions raised in candidate'
        );

        is $result, 'control', 'run() returned use() result';
    };

=for ruby

  it "passes through exceptions raised by the control behavior" do
    @ex.use { raise "control" }
    @ex.try { "candidate" }

    exception = assert_raises RuntimeError do
      @ex.run
    end

    assert_equal "control", exception.message
  end

=cut

    subtest "passes through exceptions raised by the control behavior" => sub {
        my $ex = Fake->new(
            use => sub { die 'control' },
            try => sub { 'candidate' },
        );

        like(
            dies { $ex->run },
            qr/control/,
            'exceptions raised by candidate are propagated'
        );
    };

=for ruby

  it "shuffles behaviors before running" do
    last = nil
    runs = []

    @ex.use { last = "control" }
    @ex.try { last = "candidate" }

    10000.times do
      @ex.run
      runs << last
    end

    assert runs.uniq.size > 1
  end

=cut

    subtest "shuffles behaviors before running" => sub {
        pass; # tested by random_behavior.t
    };

=for ruby

  it "re-raises exceptions raised during publish by default" do
    ex = Scientist::Experiment.new("hello")
    assert_kind_of Scientist::Default, ex
    def ex.publish(result)
      raise "boomtown"
    end

    ex.use { "control" }
    ex.try { "candidate" }

    exception = assert_raises RuntimeError do
      ex.run
    end

    assert_equal "boomtown", exception.message
  end

=cut

    subtest "re-raises exceptions raised during publish by default" => sub {
        my $mock = mock Fake => (
            override => [
                publish => sub { die "boomtown" },
            ],
        );

        my $ex = Fake->new(
            use => sub { 'control' },
            try => sub { 'candidate' },
        );

        like(
            dies { $ex->run },
            qr/boomtown/,
            'die in publish() should die'
        );
    };

=for ruby

  it "reports publishing errors" do
    def @ex.publish(result)
      raise "boomtown"
    end

    @ex.use { "control" }
    @ex.try { "candidate" }

    assert_equal "control", @ex.run

    op, exception = @ex.exceptions.pop

    assert_equal :publish, op
    assert_equal "boomtown", exception.message
  end

=cut

    todo "reports publishing errors" => sub {
        my $mock = mock Fake => (
            override => [
                publish => sub { die "boomtown" },
            ],
        );

        my $ex = Fake->new(
            use => sub { 'control' },
            try => sub { 'candidate' },
        );

        my $result = try { $ex->run };
        is $result, 'control', 'run() returned control result';

        my $exc_array = pop @{ $ex->exceptions };
        my ($op, $exception) = @$exc_array;
        is $op, 'publish', 'run() died in publish()';
        like $exception, qr/boomtown/, 'run() died with the "boomtown" message';
    };

=for ruby

  it "publishes results" do
    @ex.use { 1 }
    @ex.try { 1 }
    assert_equal 1, @ex.run
    assert @ex.published_result
  end

=cut

    todo "publishes results" => sub {
        my $ex = Fake->new(
            use => sub { 1 },
            try => sub { 1 },
        );

        my $result = $ex->run;
        is $result, 1, "run() returned use()'s result value";
        ok $ex->published_result, "run() publish()ed to published_result()";
    };

=for ruby

  it "does not publish results when there is only a control value" do
    @ex.use { 1 }
    assert_equal 1, @ex.run
    assert_nil @ex.published_result
  end

=cut

    subtest "does not publish results when there is only a control value" => sub {
        my $ex = Fake->new(
            use => sub { 1 },
        );

        my $result = $ex->run;
        is $result, 1, "run() returned use()'s result value";
        ok ! $ex->published_result, "run() did not publish to published_result() without a try()";
    };

=for ruby

  it "compares results with a comparator block if provided" do
    @ex.compare { |a, b| a == b.to_s }
    @ex.use { "1" }
    @ex.try { 1 }

    assert_equal "1", @ex.run
    assert @ex.published_result.matched?
  end

=cut

    subtest "compares results with a comparator block if provided" => sub {
        todo compare_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "knows how to compare two experiments" do
    a = Scientist::Observation.new(@ex, "a") { 1 }
    b = Scientist::Observation.new(@ex, "b") { 2 }

    assert @ex.observations_are_equivalent?(a, a)
    refute @ex.observations_are_equivalent?(a, b)
  end

=cut

    subtest "knows how to compare two experiments" => sub {
        todo compare_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "uses a compare block to determine if observations are equivalent" do
    a = Scientist::Observation.new(@ex, "a") { "1" }
    b = Scientist::Observation.new(@ex, "b") { 1 }
    @ex.compare { |x, y| x == y.to_s }
    assert @ex.observations_are_equivalent?(a, b)
  end

=cut

    subtest "uses a compare block to determine if observations are equivalent" => sub {
        todo compare_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "reports errors in a compare block" do
    @ex.compare { raise "boomtown" }
    @ex.use { "control" }
    @ex.try { "candidate" }

    assert_equal "control", @ex.run

    op, exception = @ex.exceptions.pop

    assert_equal :compare, op
    assert_equal "boomtown", exception.message
  end

=cut

    subtest "reports errors in a compare block" => sub {
        todo compare_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "reports errors in the enabled? method" do
    def @ex.enabled?
      raise "kaboom"
    end

    @ex.use { "control" }
    @ex.try { "candidate" }
    assert_equal "control", @ex.run

    op, exception = @ex.exceptions.pop

    assert_equal :enabled, op
    assert_equal "kaboom", exception.message
  end

=cut

    todo "reports errors in the enabled? method" => sub {
        my $mock = mock $CLASS => (
            override => [
                enabled => sub { die "kaboom" },
            ],
        );

        my $ex = Fake->new(
            use => sub { 'control' },
            try => sub { 'candidate' },
        );

        is $ex->run, 'control', 'run() returned control result';

        my $exc_array = pop @{ $ex->exceptions };
        my ($op, $exception) = @$exc_array;
        is $op, 'enabled', 'run() died in enabled()';
        like $exception, qr/kaboom/, 'run() died with the "kaboom" message';
    };

=for ruby

  it "reports errors in a run_if block" do
    @ex.run_if { raise "kaboom" }
    @ex.use { "control" }
    @ex.try { "candidate" }
    assert_equal "control", @ex.run

    op, exception = @ex.exceptions.pop

    assert_equal :run_if, op
    assert_equal "kaboom", exception.message
  end

=cut

    subtest "reports errors in a run_if block" => sub {
        todo run_if_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "returns the given value when no clean block is configured" do
    assert_equal 10, @ex.clean_value(10)
  end

=cut

    subtest "returns the given value when no clean block is configured" => sub {
        todo clean_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "calls the configured clean block with a value when configured" do
    @ex.clean do |value|
      value.upcase
    end

    assert_equal "TEST", @ex.clean_value("test")
  end

=cut

    subtest "calls the configured clean block with a value when configured" => sub {
        todo clean_unimplemented => sub {
            fail;
        };
    };

=for ruby

  it "reports an error and returns the original value when an error is raised in a clean block" do
    @ex.clean { |value| raise "kaboom" }

    @ex.use { "control" }
    @ex.try { "candidate" }
    assert_equal "control", @ex.run

    assert_equal "control", @ex.published_result.control.cleaned_value

    op, exception = @ex.exceptions.pop

    assert_equal :clean, op
    assert_equal "kaboom", exception.message
  end

=cut

    subtest "reports an error and returns the original value when an error is raised in a clean block" => sub {
        todo clean_unimplemented => sub {
            fail;
        };
    };

}; # end describe_experiment

=for ruby

describe "#run_if" do
    it "does not run the experiment if the given block returns false" do
      candidate_ran = false
      run_check_ran = false

      @ex.use { 1 }
      @ex.try { candidate_ran = true; 1 }

      @ex.run_if { run_check_ran = true; false }

      @ex.run

      assert run_check_ran
      refute candidate_ran
    end

=cut

subtest describe_run_if => sub {

    subtest "does not run the experiment if the given block returns false" => sub {
        todo run_if_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "runs the experiment if the given block returns true" do
      candidate_ran = false
      run_check_ran = false

      @ex.use { true }
      @ex.try { candidate_ran = true }

      @ex.run_if { run_check_ran = true }

      @ex.run

      assert run_check_ran
      assert candidate_ran
    end
  end


=cut

    subtest "runs the experiment if the given block returns true" => sub {
        todo run_if_unimplemented => sub {
            fail;
        };
    };

=for ruby

  describe "#ignore_mismatched_observation?" do
    before do
      @a = Scientist::Observation.new(@ex, "a") { 1 }
      @b = Scientist::Observation.new(@ex, "b") { 2 }
    end

=cut

    subtest "ignore_mismatched_observation" => sub {
        todo scientist_observation_class_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "does not ignore an observation if no ignores are configured" do
      refute @ex.ignore_mismatched_observation?(@a, @b)
    end

=cut

    subtest "does not ignore an observation if no ignores are configured" => sub {
        todo scientist_observation_class_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "calls a configured ignore block with the given observed values" do
      called = false
      @ex.ignore do |a, b|
        called = true
        assert_equal @a.value, a
        assert_equal @b.value, b
        true
      end

      assert @ex.ignore_mismatched_observation?(@a, @b)
      assert called
    end

=cut

    subtest "calls a configured ignore block with the given observed values" => sub {
        todo ignore_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "calls multiple ignore blocks to see if any match" do
      called_one = called_two = called_three = false
      @ex.ignore { |a, b| called_one   = true; false }
      @ex.ignore { |a, b| called_two   = true; false }
      @ex.ignore { |a, b| called_three = true; false }
      refute @ex.ignore_mismatched_observation?(@a, @b)
      assert called_one
      assert called_two
      assert called_three
    end

=cut

    subtest "calls multiple ignore blocks to see if any match" => sub {
        todo ignore_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "only calls ignore blocks until one matches" do
      called_one = called_two = called_three = false
      @ex.ignore { |a, b| called_one   = true; false }
      @ex.ignore { |a, b| called_two   = true; true  }
      @ex.ignore { |a, b| called_three = true; false }
      assert @ex.ignore_mismatched_observation?(@a, @b)
      assert called_one
      assert called_two
      refute called_three
    end

=cut

    subtest "only calls ignore blocks until one matches" => sub {
        todo ignore_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "reports exceptions raised in an ignore block and returns false" do
      def @ex.exceptions
        @exceptions ||= []
      end

      def @ex.raised(op, exception)
        exceptions << [op, exception]
      end

      @ex.ignore { raise "kaboom" }

      refute @ex.ignore_mismatched_observation?(@a, @b)

      op, exception = @ex.exceptions.pop
      assert_equal :ignore, op
      assert_equal "kaboom", exception.message
    end

=cut

    subtest "reports exceptions raised in an ignore block and returns false" => sub {
        todo ignore_unimplemented => sub {
            fail;
        };
        todo raised_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "skips ignore blocks that raise and tests any remaining blocks if an exception is swallowed" do
      def @ex.exceptions
        @exceptions ||= []
      end

      # this swallows the exception rather than re-raising
      def @ex.raised(op, exception)
        exceptions << [op, exception]
      end

      @ex.ignore { raise "kaboom" }
      @ex.ignore { true }

      assert @ex.ignore_mismatched_observation?(@a, @b)
      assert_equal 1, @ex.exceptions.size
    end
  end

=cut

    subtest "skips ignore blocks that raise and tests any remaining blocks if an exception is swallowed" => sub {
        todo ignore_unimplemented => sub {
            fail;
        };
        todo raised_unimplemented => sub {
            fail;
        };
    };

=for ruby

  describe "raising on mismatches" do
    before do
      @old_raise_on_mismatches = Fake.raise_on_mismatches?
    end

    after do
      Fake.raise_on_mismatches = @old_raise_on_mismatches
    end

=cut

    subtest "raising on mismatches" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "raises when there is a mismatch if raise on mismatches is enabled" do
      Fake.raise_on_mismatches = true
      @ex.use { "fine" }
      @ex.try { "not fine" }

      assert_raises(Scientist::Experiment::MismatchError) { @ex.run }
    end

=cut

    subtest "raises when there is a mismatch if raise on mismatches is enabled" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "doesn't raise when there is a mismatch if raise on mismatches is disabled" do
      Fake.raise_on_mismatches = false
      @ex.use { "fine" }
      @ex.try { "not fine" }

      assert_equal "fine", @ex.run
    end

=cut

    subtest "doesn't raise when there is a mismatch if raise on mismatches is disabled" => sub {
        my $ex = Fake->new(
            use => sub { "fine" },
            try => sub { "not fine" },
        );

        is $ex->run(), "fine", "did not die on mismatch";
    };

=for ruby

    it "raises a mismatch error if the control raises and candidate doesn't" do
      Fake.raise_on_mismatches = true
      @ex.use { raise "control" }
      @ex.try { "candidate" }
      assert_raises(Scientist::Experiment::MismatchError) { @ex.run }
    end

=cut

    subtest "raises a mismatch error if the candidate raises and the control doesn't" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "raises a mismatch error if the candidate raises and the control doesn't" do
      Fake.raise_on_mismatches = true
      @ex.use { "control" }
      @ex.try { raise "candidate" }
      assert_raises(Scientist::Experiment::MismatchError) { @ex.run }
    end

=cut

    subtest "raises when there is a mismatch if the experiment instance's raise on mismatches is enabled" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

}; # end describe_run_if

=for ruby

    describe "#raise_on_mismatches?" do
      it "raises when there is a mismatch if the experiment instance's raise on mismatches is enabled" do
        Fake.raise_on_mismatches = false
        @ex.raise_on_mismatches = true
        @ex.use { "fine" }
        @ex.try { "not fine" }

        assert_raises(Scientist::Experiment::MismatchError) { @ex.run }
      end

=cut

subtest describe_raise_on_mismatches => sub {


=for ruby

      it "doesn't raise when there is a mismatch if the experiment instance's raise on mismatches is disabled" do
        Fake.raise_on_mismatches = true
        @ex.raise_on_mismatches = false
        @ex.use { "fine" }
        @ex.try { "not fine" }

        assert_equal "fine", @ex.run
      end

=cut

    subtest "doesn't raise when there is a mismatch if the experiment instance's raise on mismatches is disabled" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

=for ruby

      it "respects the raise_on_mismatches class attribute by default" do
        Fake.raise_on_mismatches = false
        @ex.use { "fine" }
        @ex.try { "not fine" }

        assert_equal "fine", @ex.run

        Fake.raise_on_mismatches = true

        assert_raises(Scientist::Experiment::MismatchError) { @ex.run }
      end
    end

=cut

    subtest "respects the raise_on_mismatches class attribute by default" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };
}; # end describe_raise_on_mismatches

=begin ruby

    describe "MismatchError" do
      before do
        Fake.raise_on_mismatches = true
        @ex.use { :foo }
        @ex.try { :bar }
        begin
          @ex.run
        rescue Scientist::Experiment::MismatchError => e
          @mismatch = e
        end
        assert @mismatch
      end

=cut

subtest describe_MismatchError => sub {

=for ruby

      it "has the name of the experiment" do
        assert_equal @ex.name, @mismatch.name
      end

=cut

    subtest "has the name of the experiment" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

=for ruby

      it "includes the experiments' results" do
        assert_equal @ex.published_result, @mismatch.result
      end

=cut

    subtest "includes the experiments' results" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

=for ruby

      it "formats nicely as a string" do
        assert_equal <<-STR, @mismatch.to_s
experiment 'experiment' observations mismatched:
control:
  :foo
candidate:
  :bar
        STR
      end

=cut

    subtest "formats nicely as a string" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

=for ruby

      it "includes the backtrace when an observation raises" do
        mismatch = nil
        ex = Fake.new
        ex.use { "value" }
        ex.try { raise "error" }

        begin
          ex.run
        rescue Scientist::Experiment::MismatchError => e
          mismatch = e
        end

        # Should look like this:
        # experiment 'experiment' observations mismatched:
        # control:
        #   "value"
        # candidate:
        #   #<RuntimeError: error>
        #     test/scientist/experiment_test.rb:447:in `block (5 levels) in <top (required)>'
        # ... (more backtrace)
        lines = mismatch.to_s.split("\n")
        assert_equal "control:", lines[1]
        assert_equal "  \"value\"", lines[2]
        assert_equal "candidate:", lines[3]
        assert_equal "  #<RuntimeError: error>", lines[4]
        assert_match %r(    test/scientist/experiment_test.rb:\d+:in `block), lines[5]
      end
    end
  end

=cut

    subtest "includes the backtrace when an observation raises" => sub {
        todo raise_on_mismatches_unimplemented => sub {
            fail;
        };
    };

}; # end describe_MismatchError

=for ruby
  describe "before run block" do
    it "runs when an experiment is enabled" do
      control_ok = candidate_ok = false
      before = false
      @ex.before_run { before = true }
      @ex.use { control_ok = before }
      @ex.try { candidate_ok = before }

      @ex.run

      assert before, "before_run should have run"
      assert control_ok, "control should have run after before_run"
      assert candidate_ok, "candidate should have run after before_run"
    end

=cut

subtest describe_before_run_block => sub {

    subtest "runs when an experiment is enabled" => sub {
        todo before_run_unimplemented => sub {
            fail;
        };
    };

=for ruby

    it "does not run when an experiment is disabled" do
      before = false

      def @ex.enabled?
        false
      end
      @ex.before_run { before = true }
      @ex.use { "value" }
      @ex.try { "value" }
      @ex.run

      refute before, "before_run should not have run"
    end
  end
end

=cut

    subtest "does not run when an experiment is disabled" => sub {
        todo before_run_unimplemented => sub {
            fail;
        };
    };

}; # end describe_before_run_block

done_testing;
