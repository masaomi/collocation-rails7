class JobsController < ApplicationController
  before_action :set_job, only: %i[ show edit update destroy ]

  # GET /jobs or /jobs.json
  def index
    @jobs = Job.all
    @jobs.select{|job| job.status.nil? or job.status =~ /Running/}.each do |job|
      command = "ps -p #{job.job_id}|grep -v PID"
      out = `#{command}`.chomp.strip
      if out.empty?
        job.status = "Done"
      else
        job.status = "Running"
      end
      job.save
    end
  end

  # POST
  def run
    word1=params[:word1]
    word2=params[:word2]
    new_job_id = Job.count + 1
    @job = Job.new
    @command = "ruby scripts/count_words_calc_jaccard_plus_pmi_tscore_v4.rb share/TSV_SUW_OT_all_normalized_wakachi.txt #{word1} #{word2} > job_results/job_#{new_job_id}.txt 2>&1"
    @job.link = "job_results/job_#{new_job_id}.txt"
    @job.command = @command
    pid = spawn("#{@command}")
    #p pid
    @job.job_id = pid
    @job.save
  end

  # GET static
  def result
    render file: "job_results/job_#{params[:id]}.txt", layout: false, content_type: 'text/plain'
  end

  # GET /jobs/1 or /jobs/1.json
  def show
  end

  # GET /jobs/new
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs or /jobs.json
  def create
    @job = Job.new(job_params)

    respond_to do |format|
      if @job.save
        format.html { redirect_to job_url(@job), notice: "Job was successfully created." }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1 or /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to job_url(@job), notice: "Job was successfully updated." }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1 or /jobs/1.json
  def destroy
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url, notice: "Job was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def job_params
      params.require(:job).permit(:job_id, :status, :link)
    end
end
