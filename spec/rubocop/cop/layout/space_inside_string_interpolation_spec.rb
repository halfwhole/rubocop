# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideStringInterpolation, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    context 'for ill-formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<-'RUBY'.strip_indent)
          "#{ var}"
             ^ Space inside string interpolation detected.
          "#{var }"
                ^ Space inside string interpolation detected.
          "#{   var   }"
             ^^^ Space inside string interpolation detected.
                   ^^^ Space inside string interpolation detected.
          "#{var	}"
                ^ Space inside string interpolation detected.
          "#{	var	}"
             ^ Space inside string interpolation detected.
                 ^ Space inside string interpolation detected.
          "#{	var}"
             ^ Space inside string interpolation detected.
          "#{ 	 var 	 	}"
             ^^^ Space inside string interpolation detected.
                   ^^^^ Space inside string interpolation detected.
        RUBY

        expect_correction(<<-'RUBY'.strip_indent)
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
          "#{var}"
        RUBY
      end

      it 'finds interpolations in string-like contexts' do
        expect_offense(<<-'RUBY'.strip_indent)
          /regexp #{ var}/
                    ^ Space inside string interpolation detected.
          `backticks #{ var}`
                       ^ Space inside string interpolation detected.
          :"symbol #{ var}"
                     ^ Space inside string interpolation detected.
        RUBY

        expect_correction(<<-'RUBY'.strip_indent)
          /regexp #{var}/
          `backticks #{var}`
          :"symbol #{var}"
        RUBY
      end
    end

    context 'for "space" style formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<-'RUBY'.strip_indent)
          "#{ var }"
             ^ Space inside string interpolation detected.
                 ^ Space inside string interpolation detected.
        RUBY

        expect_correction(<<-'RUBY'.strip_indent)
          "#{var}"
        RUBY
      end
    end

    it 'does not touch spaces inside the interpolated expression' do
      expect_offense(<<-'RUBY'.strip_indent)
        "#{ a; b }"
           ^ Space inside string interpolation detected.
                ^ Space inside string interpolation detected.
      RUBY

      expect_correction(<<-'RUBY'.strip_indent)
        "#{a; b}"
      RUBY
    end

    context 'for well-formatted string interpolations' do
      let(:source) do
        <<-'RUBY'.strip_indent
          "Variable is    #{var}      "
          "  Variable is  #{var}"
        RUBY
      end

      it 'does not register an offense for excess literal spacing' do
        expect_no_offenses(source)
      end

      it 'does not correct valid string interpolations' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end
    end

    it 'accepts empty interpolation' do
      expect_no_offenses("\"\#{}\"")
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    context 'for ill-formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<-'RUBY'.strip_indent)
          "#{ var}"
                 ^ Missing space inside string interpolation detected.
          "#{var }"
           ^^ Missing space inside string interpolation detected.
          "#{   var   }"
          "#{var	}"
           ^^ Missing space inside string interpolation detected.
          "#{	var	}"
          "#{	var}"
                 ^ Missing space inside string interpolation detected.
          "#{ 	 var 	 	}"
        RUBY

        # Extra space is handled by ExtraSpace cop.
        expect_correction(<<-'RUBY'.strip_indent)
          "#{ var }"
          "#{ var }"
          "#{   var   }"
          "#{ var	}"
          "#{	var	}"
          "#{	var }"
          "#{ 	 var 	 	}"
        RUBY
      end
    end

    context 'for "no_space" style formatted string interpolations' do
      it 'registers offenses and autocorrects' do
        expect_offense(<<-'RUBY'.strip_indent)
          "#{var}"
           ^^ Missing space inside string interpolation detected.
                ^ Missing space inside string interpolation detected.
        RUBY

        expect_correction(<<-'RUBY'.strip_indent)
          "#{ var }"
        RUBY
      end
    end

    context 'for well-formatted string interpolations' do
      let(:source) do
        <<-'RUBY'.strip_indent
          "Variable is    #{ var }      "
          "  Variable is  #{ var }"
        RUBY
      end

      it 'does not register an offense for excess literal spacing' do
        expect_no_offenses(source)
      end

      it 'does not correct valid string interpolations' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end
    end

    it 'accepts empty interpolation' do
      expect_no_offenses("\"\#{}\"")
    end
  end
end
