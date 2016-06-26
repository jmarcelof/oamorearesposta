class FirstContactFilesController < ApplicationController

  def index
    @first_contact_files = FirstContactFile.all.paginate( :page => params[ :page ] )
  end

  def show
    @first_contact_file = FirstContactFile.find(params[:id])
  end

  def new
    @first_contact_file = FirstContactFile.new(
      is_new_partner: true,
      beneficiary: Beneficiary.new(person: Person.new(address: Address.new())),
      support: Person.new(phones: [Phone.new]),
      date: Date.today.strftime('%d/%m/%Y'),
      contact_source: Person.new(phones: [Phone.new]))
  end

  def create
    @file = current_user.first_contact_files.new(form_params)
    if @file.save
      redirect_to @file,
        notice: t('controllers.actions.create.success', model: FirstContactFile.model_name.human(count: 1))
    end
  end

  private
  def form_params
    params.require(:first_contact_file).permit(
      :date, :hour, :institution, :operational_context_first_contact,
      :how_established_first_contact, :contact_source_type,
      :how_person_knew_about_the_organization,
      :beneficiary_and_contact_source_relationship,
      :is_new_partner, :number_of_previous_treatments,
      :place_of_previous_treatments, :marital_status,
      :number_sons, :number_daughters, :ethnic_group, :religion,
      :family_structure, :job, :comments, :user,
      :education_levels => [],
      :answer => [],
      :petitions => [],
      :results => [],
      :first_contact_conditions => [],
      :beneficiary_attributes => [
        :department_id,
        :person_attributes => [
          :first_name,
          :last_name,
          :birthdate,
          :age,
          :gender,
          :email,
          :address_attributes => [
            :street,
            :neighborhood,
            :number,
            :cep,
            :complement,
            :city_id
          ]
        ],
      ],
      :contact_source_attributes => [
        :first_name,
        :age,
        :gender,
        [:phones_attributes => [:number]]
      ],
      :support_attributes => [
        :first_name,
        [:phones_attributes => [:number]]
      ])
  end

end
