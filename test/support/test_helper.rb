require 'fileutils'

module TestHelper
	STUB_TEMP_DIR = 'tmp.stub'

	class Stub
		attr_reader :app_root
		
		def initialize(name)
			@name = name
			@app_root = STUB_TEMP_DIR
		end
		
		def environment_rb
			return "#{@app_root}/config/environment.rb"
		end
		
		def use_vendor_rails(name)
			FileUtils.cp_r("stub/vendor_rails/#{name}", "#{@app_root}/vendor/rails")
		end
		
		def dont_use_vendor_rails
			FileUtils.rm_rf("#{@app_root}/vendor/rails")
		end
	end
	
	def setup_rails_stub(name)
		FileUtils.rm_rf(STUB_TEMP_DIR)
		FileUtils.mkdir_p(STUB_TEMP_DIR)
		FileUtils.cp_r("stub/rails_apps/#{name}/.", STUB_TEMP_DIR)
		FileUtils.mkdir_p("#{STUB_TEMP_DIR}/log")
		system("chmod", "-R", "a+rw", STUB_TEMP_DIR)
		return Stub.new(name)
	end
	
	def teardown_rails_stub
		FileUtils.rm_rf(STUB_TEMP_DIR)
	end
	
	def use_rails_stub(name)
		yield setup_rails_stub(name)
	ensure
		teardown_rails_stub
	end
end

File.class_eval do
	def self.prepend(filename, data)
		original_content = File.read(filename)
		File.open(filename, 'w') do |f|
			f.write(data)
			f.write(original_content)
		end
	end
	
	def self.append(filename, data)
		File.open(filename, 'a') do |f|
			f.write(data)
		end
	end

	def self.write(filename, content = nil)
		if block_given?
			content = yield File.read(filename)
		end
		File.open(filename, 'w') do |f|
			f.write(content)
		end
	end
end
