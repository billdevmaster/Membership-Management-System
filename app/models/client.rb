class Client < ApplicationRecord
  has_many :purchases, dependent: :destroy
  has_many :attendances, through: :purchases
  belongs_to :account, optional: true
  before_save :downcase_email
  # validates :first_name, uniqueness: {scope: :last_name}
  validates :first_name, presence: true, length: { maximum: 40 }
  validates :last_name, presence: true, length: { maximum: 40 }
  validate :full_name_must_be_unique
  # validates :email, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :phone, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :whatsapp, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :instagram, uniqueness: { case_sensitive: false }, allow_blank: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  # note allow_blank will skip the validations on blank fields so multiple clients
  # with blank email will not fall foul of the uniqueness requirement
  validates :email, allow_blank: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :account, presence: true, if: :account_id
  scope :order_by_name, -> { order(:first_name, :last_name) }
  scope :name_like, ->(name) { where("first_name ILIKE ? OR last_name ILIKE ?", "%#{name}%", "%#{name}%") }
  # https://stackoverflow.com/questions/9613717/rails-find-record-with-zero-has-many-records-associated
  scope :enquiry, -> { left_outer_joins(:purchases).where(purchases: {id: nil}) }
  scope :hot, -> { where(hotlead: true) }
  # cold failed as a class method (didn't mix well with Client.includes(:account) in the controller. Don't understand why.)
  scope :cold, -> { clients = Client
                      .select('clients.id', 'max(start_time) as max')
                      .joins(purchases: [attendances: [:wkclass]])
                      .group('clients.id')
                      .having("max(start_time) < ?", 3.months.ago)
                    Client.where(id: clients.map(&:id))
                  }
  paginates_per 20

  def self.to_csv
    CSV.generate(row_sep: "\n") do |csv|
      csv << column_names
      all.each do |client|
        csv << client.attributes.values_at(*column_names)
      end
    end
  end

  # def self.cold
  #     sql = "SELECT client_id, max(start_time)
  #            FROM clients INNER JOIN purchases ON purchases.client_id = clients.id
  #            INNER JOIN attendances ON attendances.purchase_id = purchases.id
  #            INNER JOIN wkclasses ON attendances.wkclass_id = wkclasses.id
  #            GROUP BY client_id
  #            HAVING max(start_time) > CURRENT_DATE - INTERVAL '1 months';"
  #     ActiveRecord::Base.connection.exec_query(sql).to_a
  # end

  def cold?
    date_of_last_class = attendances.includes(:wkclass).map { |a| a.wkclass.start_time }.max
    return false if date_of_last_class.nil?
    date_of_last_class < 3.months.ago
  end

  # alternative code if wanting to loop through an array of clients
  # cold_client_id_array = Client.cold.pluck(:id)
  # Client.limit(3).map {|c| c.cold2?(cold_client_id_array)}
  def cold2?(cold_client_id_array)
    # Client.cold.where(id: self.id).exists?
    cold_client_id_array.include?(self.id)
  end

  def enquiry?
    Client.enquiry.where(id: self.id).exists?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def last_class
    attendances.confirmed.includes(:wkclass).map(&:start_time).max
  end

  def total_spend
    purchases.map(&:payment).inject(0, :+)
  end

  def last_purchase
    purchases.order_by_dop.first
  end

  # def products_for_class(wkclass)
  #   # Product.find(self.purchase_for_class(wkclass).product_id)
  #   Product.find(self.purchases_for_class(wkclass).pluck(:product_id))
  # end

  # def revenue_for_class(wkclass)
  #   #wkclass.purchases.where(client_id: self.id).first.payment / self.purchase_for_class(wkclass).attendance_estimate
  # end

  private
    def downcase_email
      self.email = email.downcase
    end

    # def purchases_for_class(wkclass)
    #   # wkclass.purchases.where(client_id: self.id).first
    #   wkclass.purchases.where(client_id: self.id)
    # end

    def full_name_must_be_unique
      # complicated due to situation on update. There will of course be one record in the database
      # with the relevant name on update (the record we are updating) and we don't want its presence
      # to trigger warnings. We don't however want an exisitng record to have its name changed to
      # a name that is the same of a (different) already existing record. Note the id of a new record
      # (not yet saved) will be nil (so won't be equal to the id of any saved record.)
      client = Client.where(["first_name = ? and last_name = ?", first_name, last_name])
      client.each do |c|
        if id != client.first.id
          errors.add(:base, "Client named #{first_name} #{last_name} already exists") if client.present?
        return
        end
      end
    end
end
