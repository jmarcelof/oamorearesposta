class BeneficiariesController < ApplicationController
    respond_to :html, :xml, :json

    before_action :set_beneficiary, only: [:show, :edit]

    def autocomplete_beneficiary_name
        render json: to_autocomplete_items(Beneficiary.by_name_and_status(person_name: params[:q]))
    end

    def edit
    end

    def show
    end

    def index
        @beneficiaries = Beneficiary.by_code_name_and_department(params).paginate(page: params[:page]).order(:id)
    end

    def destroy
        @beneficiary = Beneficiary.find(params[:id])
        @beneficiary.is_active = false
        @beneficiary.save
        redirect_to beneficiaries_path, notice: t('controllers.actions.destroy.success', model: Beneficiary.model_name.human(count: 1))
    end

    def report
        @data = []
        beneficiaries = Beneficiary.report_search(params) if params["group_option"]
        unless beneficiaries.nil?
            case params["group_option"]
            when "people.gender"
                beneficiaries.group_by(&:gender).each do |b|
                    @data << {y: b[1].count, legendText: t("enum.person.gender.#{Person.genders.keys[b[0]]}"), beneficiaries: b[1], sort: t("enum.person.gender.#{Person.genders.keys[b[0]]}")}
                end
             when "year_date"
                grouped_beneficiaries = beneficiaries.group_by {|b| b.date.year }
                grouped_beneficiaries.each do |l|
                    @data << {y: l[1].count, legendText: l[1].first.date.strftime('%Y'), beneficiaries: l[1], sort: l[1].first.date.year}
                end
            when "month_year_date"
                grouped_beneficiaries = beneficiaries.group_by {|b| b.date.beginning_of_month }
                grouped_beneficiaries.each do |l|
                    @data << {y: l[1].count, legendText: l[1].first.date.strftime('%m/%Y'), beneficiaries: l[1], sort: l[1].first.date.beginning_of_month}
                end
            when "first_contact_files.education_levels"
                group_by_education_lavel = Hash.new{|hash, key| hash[key] = Array.new;}
                beneficiaries.each do |b|
                    FirstContactFile.education_levels.values.each do |el|
                        group_by_education_lavel[el] << b  if b.education_levels.include? el.to_s
                    end
                end
                group_by_education_lavel.each do |b|
                    @data << {y: b[1].count, legendText: t("enumerize.first_contact_file.education_levels.#{b[0]}"), beneficiaries: b[1], sort: t("enumerize.first_contact_file.education_levels.#{b[0]}")}
                end
            when "first_contact_files.first_contact_conditions"
                group_by_first_contact_conditions = Hash.new{|hash, key| hash[key] = Array.new;}
                beneficiaries.each do |b|
                    FirstContactFile.first_contact_conditions.values.each do |fcc|
                        group_by_first_contact_conditions[fcc] << b  if b.first_contact_conditions.include? fcc.to_s
                    end
                end
                group_by_first_contact_conditions.each do |b|
                    @data << {y: b[1].count, legendText: t("enumerize.first_contact_file.first_contact_conditions.#{b[0]}"), beneficiaries: b[1], sort: t("enumerize.first_contact_file.first_contact_conditions.#{b[0]}")}
                end
            when "first_contact_files.results"
                group_by_results = Hash.new{|hash, key| hash[key] = Array.new;}
                beneficiaries.each do |b|
                    FirstContactFile.results.values.each do |i|
                        group_by_results[i] << b  if b.results.include? i.to_s
                    end
                end
                group_by_results.each do |b|
                    @data << {y: b[1].count, legendText: t("enumerize.first_contact_file.results.#{b[0]}"), beneficiaries: b[1], sort: t("enumerize.first_contact_file.results.#{b[0]}")}
                end
            when "first_contact_files.answer"
                group_by_answer = Hash.new{|hash, key| hash[key] = Array.new;}
                beneficiaries.each do |b|
                    FirstContactFile.answer.values.each do |i|
                        group_by_answer[i] << b  if b.answer.include? i.to_s
                    end
                end
                group_by_answer.each do |b|
                    @data << {y: b[1].count, legendText: t("enumerize.first_contact_file.answer.#{b[0]}"), beneficiaries: b[1], sort: t("enumerize.first_contact_file.answer.#{b[0]}")}
                end
            when "first_contact_files.how_established_first_contact"
                group_by_how_established_first_contact = Hash.new{|hash, key| hash[key] = Array.new;}
                beneficiaries.each do |b|
                    FirstContactFile.how_established_first_contacts.values.each do |i|
                        group_by_how_established_first_contact[i] << b  if b.how_established_first_contact == i
                    end
                end
                group_by_how_established_first_contact.each do |b|
                    @data << {y: b[1].count, legendText: t("enum.first_contact_file.how_established_first_contacts.#{FirstContactFile.how_established_first_contacts.key(b[0])}"), beneficiaries: b[1], sort: t("enum.first_contact_file.how_established_first_contacts.#{FirstContactFile.how_established_first_contacts.key(b[0])}")}
                end
            when "first_contact_files.marital_status"
                group_by_marital_status = Hash.new{|hash, key| hash[key] = Array.new;}
                beneficiaries.each do |b|
                    FirstContactFile.how_established_first_contacts.values.each do |i|
                        group_by_marital_status[i] << b  if b.marital_status == i
                    end
                end
                group_by_marital_status.each do |b|
                    @data << {y: b[1].count, legendText: t("enum.first_contact_file.marital_status.#{FirstContactFile.marital_statuses.key(b[0])}"), beneficiaries: b[1], sort: t("enum.first_contact_file.marital_status.#{FirstContactFile.marital_statuses.key(b[0])}")}
                end
            end
            gon.data = @data.sort_by { |e| e[:sort]  }
        end
    end

    private

    def set_beneficiary
        @beneficiary = Beneficiary.find(params[:id])
    end

    def to_autocomplete_items items
        items.collect do |item|
            [item.id.to_s, item.to_s]
        end
    end
end
