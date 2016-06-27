class User < ActiveRecord::Base
	enum role: [ :admin, :social_worker, :psycologist, :educator, :coordinator, :user ]
	after_initialize :set_default_role, :if => :new_record?

	def set_default_role
		self.role ||= :user
	end

	belongs_to :person, dependent: :destroy
	has_many :first_contact_files, inverse_of: :user
	validates_associated :person
	validates_presence_of :person
	validate :email_presence

	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :confirmable,
		:recoverable, :trackable, :validatable, :timeoutable

	def active_for_authentication?
		super && is_active
	end

	def inactive_message
		is_active ? super : "Usuário desativado."
	end

	def email_presence
	  if person.email.nil? or person.email.blank?
	  	errors[:email] << "Email deve ser informado."
	  end
	end
end
