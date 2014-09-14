require 'rspec'

module Airborne
	module RequestExpectations
		include RSpec

		def expect_json_types(expectations)
			expect_json_types_impl(expectations, body)
		end

		def expect_json(expectations)
			expect_json_impl(expectations, body)
		end

		def expect_status(code)
			expect(response.code).to eq(code)
		end

		def expect_header(key, content)
			header = headers[key]
			if header
				expect(header.downcase).to eq(content.downcase)
			else
				raise "Header #{key} not present in HTTP response"
			end
		end

		def expect_header_contains(key, content)
			header = headers[key]
			if header
				expect(header.downcase).to include(content.downcase)
			else
				raise "Header #{key} not present in HTTP response"
			end
		end

		private

		def get_mapper
			base_mapper = {
				integer: [Fixnum,Bignum],
				int: [Fixnum,Bignum],
				float: [Float],
				string: [String],
				boolean: [TrueClass, FalseClass],
				bool: [TrueClass, FalseClass],
				object: [Hash],
				array: [Array]
			}

			mapper = base_mapper.clone
			base_mapper.each do |key, value|
				mapper[(key.to_s + "_or_null").to_sym] = value + [NilClass]
			end
			mapper
		end

		def expect_json_types_impl(expectations, hash)
			@mapper ||= get_mapper
			expectations.each do |prop_name, expected_type|
				value = hash[prop_name]
				if expected_type.class == Hash
					expect_json_types_impl(expected_type, value)
				else
					expect(@mapper[expected_type].include?(value.class)).to eq(true), "Expected #{prop_name} to be of type #{expected_type}, got #{value.class} instead"
				end
			end
		end

		def expect_json_impl(expectations, hash)
			expectations.each do |prop_name, value|
				val = hash[prop_name]
				if(val.class == Hash)
					expect_json_impl(value, val)
				else
					expect(value).to eq(val)
				end
			end
		end
	end
end