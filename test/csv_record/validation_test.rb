require_relative '../test_helper'
require 'pry'
require_relative '../models/jedi'
require_relative '../models/jedi_order'
require_relative '../models/custom_errors_class'

describe CsvRecord::Validations do
  let (:invalid_jedi) { Jedi.new }

  describe 'initializing class methods' do
    it ('responds to validates_presence_of') { Jedi.must_respond_to :validates_presence_of }
    it ('responds to validates_uniqueness_of') { Jedi.must_respond_to :validates_uniqueness_of }
  end

  describe 'initializing instance methods' do
    it ('responds to valid?') { Jedi.new.must_respond_to :valid? }
    it ('responds to invalid?') { Jedi.new.must_respond_to :invalid? }
    it ('responds to errors') { Jedi.new.must_respond_to :errors }
  end

  describe 'validates_presence_of :name and :age behavior' do
    it 'is not valid without name' do
      yoda.name = nil
      yoda.valid?.wont_equal true
    end

    it 'is not valid without age' do
      yoda.age = nil
      yoda.valid?.wont_equal true
    end

    it "is valid with all attributes filled" do
      yoda.valid?.must_equal true
    end

    it "saves with both attributes filled" do
      yoda.save.must_equal true
    end

    it "doesn't save without name" do
      yoda.name = nil
      yoda.valid?.wont_equal true
      yoda.save.wont_equal true
    end

    it "doesn't save without age" do
      yoda.age = nil
      yoda.valid?.wont_equal true
      yoda.save.wont_equal true
    end

    it "doesn't save without both" do
      yoda.age = nil
      yoda.name = nil
      yoda.valid?.wont_equal true
      yoda.save.wont_equal true
    end

  end

  describe 'invalid?' do
    it 'invalid object' do
      invalid_jedi.invalid?.must_equal true
    end

    it 'valid object' do
      yoda.invalid?.must_equal false
    end
  end

  describe 'errors' do
    it 'wont be empty when invalid' do
      invalid_jedi.valid?
      invalid_jedi.errors.wont_be_empty
    end

    it 'should have two erros' do
      invalid_jedi.valid?
      invalid_jedi.errors.length.must_equal 2
    end

    it 'should contain the errors found' do
      invalid_jedi.valid?
      invalid_jedi.errors.must_include :name
      invalid_jedi.errors.must_include :age
    end

    describe 'add' do
      it ('responds to add') { invalid_jedi.errors.must_respond_to :add }

      it 'adding' do
        invalid_jedi.instance_eval do
          self.errors.add(:testing)
          self.errors.wont_be_empty
          self.errors.last.must_equal :testing
        end
      end
    end
  end

  describe 'validates_uniqueness_of' do
    before { yoda.save }

    let :fake_yoda do
      fake_yoda = Jedi.new name: 'Yoda the green', age: 238, midi_chlorians: '1k'
    end

    it 'can`t have the same name' do
      fake_yoda.valid?.must_equal false
    end
  end

  describe 'custom_validator' do
    it ('responds to validate') { CustomErrorsClass.must_respond_to :validate }

    let(:custom_error_class) { CustomErrorsClass.new }
    before { custom_error_class.valid? }

    it 'adding a custom validator' do
      custom_error_class.errors.must_include :custom_error
    end

    it 'validate can have a block' do
      custom_error_class.errors.must_include :custom_error_with_block
    end
  end

  describe 'skip validations' do
    it 'on save' do
      invalid_jedi.save(false)
      invalid_jedi.new_record?.must_equal false
    end

    it 'on update_attributes' do
      yoda.save
      yoda.update_attributes name: nil, validate: false
      yoda.name.must_be_nil
    end

    it 'update_attribute by default skips validations' do
      yoda.save
      yoda.update_attribute :name, nil
      Jedi.last.name.must_be_nil
    end
  end
end