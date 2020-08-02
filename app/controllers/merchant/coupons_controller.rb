class Merchant::CouponsController < Merchant::BaseController
  def index
    merchant = Merchant.find(current_user.merchant.id)
    @coupons = merchant.coupons
  end

  def new
    @coupon = Coupon.new
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def edit
    @coupon = Coupon.find(params[:id])
  end

  def create
    @coupon = current_user.merchant.coupons.new(coupon_params)
    if @coupon.save
      redirect_to '/merchant/coupons'
    else
      flash[:error] = @coupon.errors.full_messages.to_sentence
      render :new
    end
  end

  def update
    @coupon = Coupon.find(params[:id])
    if params[:coupon]
      @coupon.update(coupon_params)
      if @coupon.save
        redirect_to '/merchant/coupons'
      else
        flash[:error] = @coupon.errors.full_messages.to_sentence
        render :edit
      end
    elsif params[:enabled]
      @coupon.update(enabled_param)
      if @coupon.enabled
        flash[:success] = "This coupon is now Enabled"
      else
        flash[:success] = "This coupon is now Disabled"
      end
      redirect_to '/merchant/coupons'
    end
  end

  private
  def coupon_params
    params.require('coupon').permit(:name, :code, :percent_off)
  end

  def enabled_param
    params.permit(:enabled)
  end
end
