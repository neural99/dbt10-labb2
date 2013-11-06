#   Daniel Lännström
#   danlan01
#

require 'date.rb'

class Input
# Error helper function
    def self.print_error_and_wait(str)
        puts str
        gets
    end

    def self.read_date(str)
        while true
            print "#{str} (YYYY-MM-DD): "
            date = gets

            # EOF aborts 
            if date == nil
                return nil
            else 
                date = date.chomp
            end

            begin 
                # Super simple check
                # Use Date's parse method to validate date
                return Date.parse(date) if date =~ /^\d{4}\-\d{2}-\d{2}$/
                raise ArgumentError
                rescue ArgumentError
                Input.print_error_and_wait "Ogiltigt datum. Försök igen. Tryck enter för att fortsätta"
            end
        end
    end

    def self.read_phone
        while true
            print "Telefon (inkl riktnummer med bindestreck): "
            phone = gets
                
            # EOF aborts
            if phone == nil
                return nil
            else
                phone = phone.chomp
            end

            # Checks for area code but nothing fancier
            return phone if phone =~ /^\d+\-\d+$/
            print_error_and_wait "Ange riktnummer och telefonnummer. Försök ingen. Tryck enter för att fortsätta"
        end
    end

    def self.read_string(prompt)
        print prompt
        str = gets
        if str == nil
            return nil
        else 
            return str.chomp
        end
    end

    def self.read_multi_string(prompt)
        puts "Mata in " + prompt + ". Avsluta med '.' på en egen rad"
        str = []

        # Concatenate line to str 
        while true 
            tmp = gets

            # Handles EOF
            if tmp == nil
                return nil
            else
                tmp = tmp.chomp
            end

            return str if tmp == '.'
            str << tmp 
        end
        # Return the lines as a string
        return str.join("\n")
    end

    def self.read_number(prompt)
        while true
            print prompt
            num = gets

            # Use nil as EOF marker
            return nil if num == nil

            num = num.chomp
            # Make sure it's one or more digits
            return Integer(num) if num =~ /^\d+$/
            print_error_and_wait "Ej en siffra. Försök igen. Tryck enter för att fortsätta"
        end
    end
end

