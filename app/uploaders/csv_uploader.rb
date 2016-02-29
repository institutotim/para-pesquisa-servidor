# encoding: utf-8

class CSVStringIO < StringIO
  attr_accessor :filepath

  def initialize(*args)
    super(*args[1..-1])
    @filepath = args[0]
  end

  def original_filename
    File.basename(@filepath)
  end
end

class CsvUploader < CarrierWave::Uploader::Base
  def extension_white_list
    %w(csv)
  end
end