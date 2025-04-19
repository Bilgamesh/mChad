class Queue {
  constructor(maxConcurrent = Infinity) {
    this.queue = [];
    this.pendingPromises = 0;
    this.maxConcurrent = maxConcurrent;
  }

  enqueue(promiseGenerator) {
    return new Promise((resolve, reject) => {
      this.queue.push({ promiseGenerator, resolve, reject });
      this._dequeue();
    });
  }

  async _dequeue() {
    if (this.pendingPromises >= this.maxConcurrent) {
      return;
    }

    if (this.queue.length === 0) {
      return;
    }

    this.pendingPromises++;

    const { promiseGenerator, resolve, reject } = this.queue.shift();

    try {
      const result = await promiseGenerator();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.pendingPromises--;
      this._dequeue();
    }
  }
}

export { Queue };
