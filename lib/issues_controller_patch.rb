module RedmineDueDateByDefault
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          
          # run code for updating issue
          alias_method_chain :update, :write_due_date
          
          # run code for creating new issue (aka writing issue to database)
          alias_method_chain :create, :write_due_date
          
          # run code for making new issue
          alias_method_chain :new, :write_fixed_version
        end
      end

      module ClassMethods
      end

      module InstanceMethods        
        def update_with_write_due_date
          issue = Issue.find(params[:id])
                    
          begin
            new_version = Version.find(params[:issue][:fixed_version_id])
          rescue
          end           
          if params[:issue][:due_date].nil? || (params[:issue][:due_date] == '')
            if params[:issue][:start_date].exists?
              params[:issue][:due_date] = next_weekday(Time.now, 3).strftime("%m/%d/%Y").to_s
            else
              params[:issue][:start_date] = Time.now.strftime("%m/%d/Y").to_s
              params[:issue][:due_date] = next_weekday(Time.now, 3).strftime("%m/%d/%Y").to_s
            end            
          end
          
          if params[:issue][:due_date].nil? || (params[:issue][:due_date] == '')
            params[:issue][:due_date] = next_weekday(, 3).strftime("%m/%d/%Y").to_s
          end
          
          update_without_write_due_date              
        end

        def new_with_write_fixed_version
          project = Project.find(params[:project_id]) 
          field = project.custom_field_values.find {|field| field.custom_field_id == 21}
          if !field.nil?
            params[:issue] = {} if params[:issue].nil?
            build_new_issue_from_params
          end
          new_without_write_fixed_version
        end

        def create_with_write_due_date
          
          if params[:issue][:due_date].nil? || (params[:issue][:due_date] == '')
            unless params[:issue][:fixed_version_id].nil?
              begin
                v = Version.find(params[:issue][:fixed_version_id])
              rescue
              end
              params[:issue][:due_date] = next_weekday(Time.now, 3).strftime("%m/%d/%Y").to_s
            end
          end
          build_new_issue_from_params
          create_without_write_due_date
        end
        
        
        
        def next_weekday(original_date, step=1)          
          one_day = 60 * 60 * 24 * step # in Rails just say 1.day
          weekdays = 1..5        # Monday is wday 1
          result = original_date
          result += one_day until result > original_date && weekdays.member?(result.wday)
          result
        end
        
      end

    end
  end
end
