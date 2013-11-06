#!/usr/bin/env ruby -w

require 'input'
require 'pg'

tables = { "anställd" => [ ["Namn", :string], ["Lön", :integer], ["Chef", :string], ["Avd", :string] ],
           "avdelning" => [ ["Avd", :string], ["Våning", :integer] ],
           "lager" => [ ["Avd", :string], ["Varunr", :integer], ["Företag", :string], ["Volym", :integer] ],
           "vara" => [ ["Varunr", :integer], ["Typ", :string] ],
           "försäljning" => [ ["Avd", :string], ["Varunr", :integer], ["Volym", :integer] ] }

procs = { 0 => Proc.new do |table| 
               puts "Välj vilkor på sökningen (Ctrl-D för att hoppa över)\n"
               where = get_where(tables[table])

               if where == '' 
                 where = '1=1'
               end

               sql = "SELECT * FROM #{table} WHERE #{where}"
               puts sql

               tables[table].each { |x| print "#{x[0]} " }
               puts "\n"

               stat = query(sql) { |x| x.each {|k,v| print "#{v} " }; puts "\n" }
               stat.each {|k,v| puts "#{k}: #{v}\n" } 

               end,
          1 => Proc.new do |table|
               puts "Värden att sätta in i ny tupel (Ctrl-D för NULL)\n"
               sql = "INSERT INTO #{table} VALUES ("
               data = []
               tables[table].each {|arg|
                 if arg[1] == :integer 
                    i = Input.read_number("#{arg[0]}: ")
                    if i == nil
                        data << "NULL"
                        puts "\n"
                    else
                        data << i.to_s 
                    end
                 elsif arg[1] == :string
                    s = Input.read_string("#{arg[0]}: ")
                    if s == nil
                        data << "NULL"
                        puts "\n"
                    else
                        data << "\'#{s}\'"
                    end
                 else
                    p "Derp"
                 end
               } 
               sql += "#{data.join(', ')})"
               puts sql

               stat = query(sql) 
               stat.each {|k,v| puts "#{k}: #{v}\n" } 

               end,
          2 => Proc.new do |table|
               puts "Nya värden (Ctrl-D för att behålla gamla)\n"
               new_values = []

               tables[table].each do |arg|
                    if arg[1] == :integer
                        i = Input.read_number("#{arg[0]}: ")
                        if i == nil
                            puts "\n"
                        else
                            new_values << "#{arg[0]} = #{i.to_s}"
                        end
                    elsif arg[1] == :string
                        s = Input.read_string("#{arg[0]}: ")
                        if s == nil
                            puts "\n"
                        else
                            new_values << "#{arg[0]} = \'#{s}\'"
                        end
                    else
                        p "Derp"
                    end
               end
               
               puts "Vilkor (Ctrl-D för att hoppa över)\n"
               where = get_where(tables[table])
               if where == ''
                  where = '1=1'
               end
               sql = "UPDATE #{table} SET #{new_values.join(', ')} WHERE #{where}"

               puts sql

               stat = query(sql)
               stat.each {|k,v| puts "#{k}: #{v}\n" } 
                
               end,
          3 => Proc.new do |table|
               puts "Välj vilkor på borttagningen (Ctrl-D för att hoppa över)\n"
               where = get_where(tables[table])
               if where == ''
                  where = '1=1'
               end
               sql = "DELETE FROM #{table} WHERE #{where}"
               puts sql

               stat = query(sql)
               stat.each {|k,v| puts "#{k}: #{v}\n" } 

               end,
        }

def get_where(args)
    where = []
    args.each do |arg|
        if arg[1] == :integer
            i = Input.read_number("#{arg[0]}: ")
            if i != nil
                where << "#{arg[0]} = #{i}"
            else
                puts "\n"
            end
        elsif arg[1] == :string
            i = Input.read_string("#{arg[0]}: ")
            if i != nil
                where << "#{arg[0]} = \'#{i}\'"
            else
                puts "\n"
            end
        else
            p "Derp"
        end
    end
    where.join(' AND ')
end

def open_db
    $conn = PGconn.open(:dbname => 'lannst')
    if $conn.status == 0
        puts "Ansluten till DB"
    else
        puts "Fel med anslutningen till postgresql: #{$conn.get_error_message}"
        exit
    end
end

def query(sql) 
    begin
        res = $conn.exec(sql)
        if res.result_status == PGresult::PGRES_TUPLES_OK
            res.each {|x| yield x }
            { "Totalt: " => res.num_tuples }
        elsif res.result_status == PGresult::PGRES_COMMAND_OK
            { "Antalet modifierade: " => res.cmd_tuples }
        else
            # Behövs det här?
            puts "\n\nFelaktig fråga: #{res.result_error_message}\n\n"
            {}
        end
    rescue PGError
        puts "SQL Error: " + $!
        {}
    end
end

menu = []
menu << "0 - Lista"
menu << "1 - Sätt in ny"
menu << "2 - Uppdatera"
menu << "3 - Ta bort"
menu << "4 - Avsluta"

open_db
while true
    puts menu.join("\n")

    i = Input.read_number("Val: ")
    if i == 4
        exit 
    elsif procs[i] != nil 
        t = Input.read_string("Tabell: ")
        t.downcase!
        if tables[t] != nil
            procs[i].call t
        else
            Input.print_error_and_wait "Felaktig tabell"
        end
    else
        Input.print_error_and_wait "Felaktigt menyval"
    end
end
$conn.close
